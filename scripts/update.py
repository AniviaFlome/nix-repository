#!/usr/bin/env python3
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from typing import NotRequired, TypedDict, cast


class UpdateTarget(TypedDict):
    name: str
    # Whether the package carries its own updateScript (the single source of
    # truth for update flags, executed via `--use-update-script`).
    hasUpdateScript: NotRequired[bool]
    # Whether updates must land via a reviewed GitHub PR instead of direct
    # commits to main (malware guard for vendored third-party code).
    prReview: NotRequired[bool]
    # Additional attribute paths to build alongside this target when `--build`
    # verifies an update (e.g. an FHS wrapper paired with an unwrapped binary).
    extraBuildAttrs: NotRequired[list[str]]


BOT_NAME = "github-actions[bot]"
BOT_EMAIL = "github-actions[bot]@users.noreply.github.com"


def get_targets() -> list[UpdateTarget]:
    """Gets update targets using Nix evaluation against <nixpkgs>."""
    targets_cmd = [
        "nix",
        "eval",
        "--json",
        "--impure",
        "--expr",
        "import ./scripts/get-update-targets.nix { packages = import ./default.nix { }; }",
    ]
    try:
        targets_json = subprocess.run(targets_cmd, check=True, capture_output=True, text=True).stdout
        return cast(list[UpdateTarget], json.loads(targets_json))
    except subprocess.CalledProcessError as e:
        print(f"Error getting targets: {e}", file=sys.stderr)
        sys.exit(1)


def nix_update_cmd(target: UpdateTarget) -> list[str]:
    """Builds the nix-update command for a target.

    Runs all targets in file mode (`default.nix` + `maintainers/scripts/update.nix`):
    avoids Nix 2.35 lazy-trees `flakeImportPath` evaluation failures, uses
    the active `<nixpkgs>` channel instead of a potentially stale `flake.lock`,
    and honors `NIXPKGS_ALLOW_UNFREE`.

    Never passes `--build` to `nix-update` directly: with `--use-update-script`,
    `nix-update` runs `nix build` unconditionally even when no files changed,
    rebuilding the entire repo on every run. Instead, `update.py` runs
    `nix_build_cmd` only when files actually changed.
    """
    if shutil.which("nix-update"):
        cmd: list[str] = ["nix-update"]
    else:
        cmd = ["nix", "shell", "nixpkgs#nix-update", "-c", "nix-update"]

    cmd.append(target["name"])

    if target.get("hasUpdateScript", False):
        cmd.append("--use-update-script")

    return cmd


def nix_build_cmd(name: str, extra_attrs: list[str] | None = None) -> list[str]:
    """Builds the `nix build` verification command for an updated target."""
    return ["nix", "build", "--no-link", "-L", "-f", ".", name, *(extra_attrs or [])]


def git(*args: str) -> str:
    result = subprocess.run(["git", *args], check=True, capture_output=True, text=True)
    return result.stdout.strip()


def git_has_identity() -> bool:
    try:
        return bool(git("config", "user.email"))
    except subprocess.CalledProcessError:
        return False


def status_entries() -> dict[str, str]:
    """Returns `{path: XY}` from `git status --porcelain`, for per-target cleanup."""
    # NOTE: plain `git status --porcelain` output, not the `git()` helper:
    # its `.strip()` would eat the leading status column of the first line.
    result = subprocess.run(
        ["git", "status", "--porcelain"], check=True, capture_output=True, text=True
    )
    entries: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if len(line) < 4:
            continue
        code = line[:2]
        # Format is `XY PATH` (or `XY ORIG -> NEW` for renames).
        path = line[3:].split(" -> ")[-1].strip().strip('"')
        if path:
            entries[path] = code
    return entries


def dirty_files() -> set[str]:
    """Modified or untracked paths from `git status --porcelain`."""
    return set(status_entries())


def rollback_paths(after: dict[str, str], before: set[str]) -> None:
    """Reverts newly dirtied tracked files and removes newly created untracked paths."""
    for path in sorted(set(after) - before):
        try:
            if after[path] == "??":
                if os.path.isdir(path) and not os.path.islink(path):
                    shutil.rmtree(path)
                elif os.path.lexists(path):
                    os.unlink(path)
            else:
                subprocess.run(["git", "checkout", "--", path], check=True)
        except (subprocess.CalledProcessError, OSError) as ce:
            print(f"Warning: Failed to restore {path} ({ce})", file=sys.stderr)


def git_commit(message: str) -> None:
    # In CI we always force the bot identity so Author doesn't leak
    # to the workflow actor (AniviaFlome) and pollute the personal
    # contribution graph. Locally we preserve the developer's identity
    # when git config is already set.
    force_bot = os.environ.get("GITHUB_ACTIONS") == "true"
    cmd = ["git"]
    if force_bot or not git_has_identity():
        cmd += ["-c", f"user.name={BOT_NAME}", "-c", f"user.email={BOT_EMAIL}"]
    cmd += ["commit", "-am", message]
    subprocess.run(cmd, check=True, capture_output=True, text=True)


def extract_upstream_info(diff: str) -> tuple[str | None, str | None, str | None, str | None]:
    """Extracts owner/repo and old/new revs from a package file diff."""
    owner_m = re.search(r'^[-+ ]\s*owner\s*=\s*"([^"]+)"', diff, re.MULTILINE)
    repo_m = re.search(r'^[-+ ]\s*repo\s*=\s*"([^"]+)"', diff, re.MULTILINE)
    old_rev = new_rev = None
    for line in diff.splitlines():
        m = re.match(r'^([-+])\s*rev\s*=\s*"([0-9a-fA-F]{7,40})"', line)
        if m:
            if m.group(1) == "-":
                old_rev = m.group(2)
            else:
                new_rev = m.group(2)
    owner = owner_m.group(1) if owner_m else None
    repo = repo_m.group(1) if repo_m else None
    return owner, repo, old_rev, new_rev


def pr_body(target: UpdateTarget, diff: str) -> str:
    owner, repo, old_rev, new_rev = extract_upstream_info(diff)
    parts = [
        f"Automated version bump proposal for `{target['name']}`.",
        "",
        "> [!WARNING]",
        "> This package is review-gated: merging vendors new upstream code into this repository.",
        "> Review the diff below before merging — a changed `hash` alongside a changed `rev` means the vendored source itself changed.",
        "",
        "<details><summary>Patch</summary>",
        "",
        "```diff",
        diff,
        "```",
        "",
        "</details>",
    ]
    if owner and repo and old_rev and new_rev:
        parts += [
            "",
            f"[Upstream compare](https://github.com/{owner}/{repo}/compare/{old_rev}...{new_rev})",
        ]
    return "\n".join(parts)


def prs_allowed(args: argparse.Namespace) -> bool:
    """Whether review-gated PRs may be opened/edited in this environment.

    PR authorship comes from the token `gh` authenticates with: in CI
    (GITHUB_ACTIONS=true + github.token) that's github-actions[bot], but a
    local `gh` uses the developer's own token, so a local `--open-prs` run
    would create user-authored PRs. Refuse that unless explicitly overridden.
    """
    return bool(args.open_prs) and (
        os.environ.get("GITHUB_ACTIONS") == "true" or bool(getattr(args, "allow_local_prs", False))
    )


def update_pr_review_target(target: UpdateTarget, args: argparse.Namespace, base_branch: str) -> bool:
    """Updates a review-gated package on its own branch and opens/refreshes a PR."""
    name = target["name"]
    branch = "auto-update/" + name.replace(".", "-")

    print(f"Updating {name} (review-gated, branch {branch})...", flush=True)
    subprocess.run(nix_update_cmd(target), check=True)

    if not git("status", "--porcelain"):
        print(f"No changes for {name}", flush=True)
        return False

    if args.build:
        subprocess.run(nix_build_cmd(name, target.get("extraBuildAttrs")), check=True)

    diff = git("diff", "HEAD")
    git_commit(f"pkgs: auto-update {name} (review required)")
    subprocess.run(["git", "push", "--force", "origin", branch], check=True)

    body_file: str | None = None
    try:
        with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False) as f:
            f.write(pr_body(target, diff))
            body_file = f.name

        listing = subprocess.run(
            ["gh", "pr", "list", "--head", branch, "--state", "open", "--json", "number"],
            check=True, capture_output=True, text=True,
        ).stdout
        open_prs = json.loads(listing)
        if open_prs:
            number = open_prs[0]["number"]
            subprocess.run(
                ["gh", "pr", "edit", str(number), "--body-file", body_file],
                check=True,
            )
            print(f"Refreshed PR #{number} for {name}")
        else:
            subprocess.run(
                [
                    "gh", "pr", "create",
                    "--base", base_branch,
                    "--head", branch,
                    "--title", f"pkgs: auto-update {name}",
                    "--body-file", body_file,
                ],
                check=True,
            )
            print(f"Opened review PR for {name}")
    finally:
        if body_file and os.path.exists(body_file):
            os.unlink(body_file)
    return True


def write_step_summary(updated: list[str], failed: list[str]) -> None:
    """Appends update results to GitHub Actions step summary when available."""
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not summary_path:
        return
    lines = ["## Package Auto-Update Summary", ""]
    if updated:
        lines.append(f"**Updated ({len(updated)}):** " + ", ".join(f"`{n}`" for n in updated))
    else:
        lines.append("**Updated:** none")
    lines.append("")
    if failed:
        lines.append(f"**Failed ({len(failed)}):** " + ", ".join(f"`{n}`" for n in failed))
    else:
        lines.append("**Failed:** none")
    lines.append("")
    with open(summary_path, "a", encoding="utf-8") as f:
        f.write("\n".join(lines))


def main() -> None:
    parser = argparse.ArgumentParser(description="Update NUR packages using nix-update")
    parser.add_argument(
        "--build",
        action="store_true",
        help="Build each package after updating to verify it compiles (skips broken updates)",
    )
    parser.add_argument(
        "--open-prs",
        action="store_true",
        help="Propose review-gated (passthru.updatePr) package updates via GitHub PRs instead of skipping them",
    )
    parser.add_argument(
        "--allow-local-prs",
        action="store_true",
        help="Allow --open-prs outside CI (creates PRs authored by you instead of github-actions[bot]; for testing only)",
    )
    args = parser.parse_args()

    targets = [t for t in get_targets() if t.get("hasUpdateScript") is not False]

    updated: list[str] = []
    failed: list[str] = []

    pr_targets = [t for t in targets if t.get("prReview")]
    normal_targets = [t for t in targets if not t.get("prReview")]

    if pr_targets:
        if prs_allowed(args):
            base_branch = git("rev-parse", "--abbrev-ref", "HEAD")
            for target in pr_targets:
                branch = "auto-update/" + target["name"].replace(".", "-")
                try:
                    git("checkout", "-B", branch)
                    if update_pr_review_target(target, args, base_branch):
                        updated.append(target["name"])
                except (subprocess.CalledProcessError, OSError, KeyError, json.JSONDecodeError) as e:
                    print(f"Warning: Failed PR-review update for {target['name']} ({e})", file=sys.stderr)
                    if os.environ.get("GITHUB_ACTIONS") == "true":
                        print(f"::warning::Failed PR-review update for {target['name']} ({e})")
                    failed.append(target["name"])
                finally:
                    # -f discards partial changes from failed updates so they
                    # can't leak into the next target's branch or into main.
                    subprocess.run(["git", "checkout", "-f", base_branch], check=True)
        else:
            if args.open_prs:
                print(
                    "Refusing --open-prs outside CI: PRs would be authored by you "
                    "instead of github-actions[bot] (pass --allow-local-prs to override)",
                    file=sys.stderr,
                )
            skipped = ", ".join(t["name"] for t in pr_targets)
            print(f"Skipping review-gated packages (use --open-prs to propose via PRs): {skipped}")

    for target in normal_targets:
        name = target["name"]

        print(f"Updating {name}...", flush=True)

        before = dirty_files()
        try:
            _ = subprocess.run(nix_update_cmd(target), check=True)
            changed = dirty_files() - before
            if changed and args.build:
                _ = subprocess.run(nix_build_cmd(name, target.get("extraBuildAttrs")), check=True)
        except subprocess.CalledProcessError as e:
            print(f"Warning: Failed to update {name} (exit code {e.returncode})", file=sys.stderr)
            if os.environ.get("GITHUB_ACTIONS") == "true":
                print(f"::warning::Failed to update {name} (exit code {e.returncode})", flush=True)
            failed.append(name)
            # nix-update writes version/hash changes before it builds, so a
            # failed update can leave a half-bumped file behind. The workflow
            # auto-commits everything dirty at the end, so restore files this
            # target dirtied — but keep earlier targets' successful updates.
            rollback_paths(status_entries(), before)
        else:
            if changed:
                updated.append(name)

    write_step_summary(updated, failed)

    if failed:
        print(f"\nFailed to update: {', '.join(failed)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
