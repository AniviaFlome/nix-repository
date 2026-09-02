#!/usr/bin/env python3
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from typing import TypedDict, cast


class UpdateTarget(TypedDict):
    name: str
    useUpdateScript: bool
    extraArgs: list[str]
    # Whether the package has an unfree license. Unfree packages can't be
    # built via `nix-update --flake --build` (pure flake eval ignores
    # NIXPKGS_ALLOW_UNFREE), so for them we fall back to `--file default.nix`
    # which uses impure channel eval that honors the env var.
    unfree: bool
    # Whether updates must land via a reviewed GitHub PR instead of direct
    # commits to main (malware guard for vendored third-party code).
    prReview: bool


BOT_NAME = "github-actions[bot]"
BOT_EMAIL = "github-actions[bot]@users.noreply.github.com"


def get_targets() -> list[UpdateTarget]:
    """Gets update targets using Nix evaluation."""
    system_cmd = ["nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem"]
    try:
        system = subprocess.run(system_cmd, check=True, capture_output=True, text=True).stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error getting system: {e}", file=sys.stderr)
        sys.exit(1)

    # Use legacyPackages (raw package set): the flake's packages output filters
    # out nested attrsets like mpvScripts, so their entries would be missed.
    targets_cmd = [
        "nix", "eval", "--json", "--impure",
        "--apply", "pkgs: import ./scripts/get-update-targets.nix { packages = pkgs; }",
        f".#legacyPackages.{system}",
    ]
    try:
        targets_json = subprocess.run(targets_cmd, check=True, capture_output=True, text=True).stdout
        return cast(list[UpdateTarget], json.loads(targets_json))
    except subprocess.CalledProcessError as e:
        print(f"Error getting targets: {e}", file=sys.stderr)
        sys.exit(1)


def nix_update_cmd(target: UpdateTarget, build: bool) -> list[str]:
    """Builds the nix-update command for a target.

    Unfree packages can't be updated via `--flake` (pure eval ignores
    NIXPKGS_ALLOW_UNFREE), so use the default `--file default.nix` path
    (impure channel eval honors it). Free packages use `--flake`.
    """
    cmd: list[str] = ["nix", "shell", "nixpkgs#nix-update", "-c", "nix-update"]
    if not target.get("unfree", False):
        cmd.append("--flake")
    cmd.append(target["name"])

    if target.get("useUpdateScript", False):
        cmd.append("--use-update-script")

    if build:
        cmd.append("--build")

    cmd.extend(target.get("extraArgs", []))
    return cmd


def git(*args: str) -> str:
    result = subprocess.run(["git", *args], check=True, capture_output=True, text=True)
    return result.stdout.strip()


def git_has_identity() -> bool:
    try:
        return bool(git("config", "user.email"))
    except subprocess.CalledProcessError:
        return False


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
            f"[Upstream compare]({ 'https://github.com/%s/%s/compare/%s...%s' % (owner, repo, old_rev, new_rev) })",
        ]
    return "\n".join(parts)


def update_pr_review_target(target: UpdateTarget, args: argparse.Namespace, base_branch: str) -> None:
    """Updates a review-gated package on its own branch and opens/refreshes a PR."""
    name = target["name"]
    branch = "auto-update/" + name.replace(".", "-")

    print(f"Updating {name} (review-gated, branch {branch})...")
    subprocess.run(nix_update_cmd(target, args.build), check=True)

    diff = ""
    if git("status", "--porcelain"):
        diff = git("diff", "HEAD")
        git_commit(f"pkgs: auto-update {name} (review required)")
        subprocess.run(["git", "push", "--force", "origin", branch], check=True)

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
    else:
        print(f"No changes for {name}")


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
    args = parser.parse_args()

    targets = get_targets()

    failed: list[str] = []

    pr_targets = [t for t in targets if t.get("prReview")]
    normal_targets = [t for t in targets if not t.get("prReview")]

    if pr_targets:
        if args.open_prs:
            base_branch = git("rev-parse", "--abbrev-ref", "HEAD")
            for target in pr_targets:
                branch = "auto-update/" + target["name"].replace(".", "-")
                try:
                    git("checkout", "-B", branch)
                    update_pr_review_target(target, args, base_branch)
                except (subprocess.CalledProcessError, OSError, KeyError, json.JSONDecodeError) as e:
                    print(f"Warning: Failed PR-review update for {target['name']} ({e})", file=sys.stderr)
                    failed.append(target["name"])
                finally:
                    # -f discards partial changes from failed updates so they
                    # can't leak into the next target's branch or into main.
                    subprocess.run(["git", "checkout", "-f", base_branch], check=True)
        else:
            skipped = ", ".join(t["name"] for t in pr_targets)
            print(f"Skipping review-gated packages (use --open-prs to propose via PRs): {skipped}")

    for target in normal_targets:
        name = target["name"]

        print(f"Updating {name}...")

        try:
            _ = subprocess.run(nix_update_cmd(target, args.build), check=True)
        except subprocess.CalledProcessError as e:
            print(f"Warning: Failed to update {name} (exit code {e.returncode})", file=sys.stderr)
            failed.append(name)

    if failed:
        print(f"\nFailed to update: {', '.join(failed)}", file=sys.stderr)


if __name__ == "__main__":
    main()
