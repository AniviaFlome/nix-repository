#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
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


def get_targets() -> list[UpdateTarget]:
    """Gets update targets using Nix evaluation."""
    system_cmd = ["nix", "eval", "--impure", "--raw", "--expr", "builtins.currentSystem"]
    try:
        system = subprocess.run(system_cmd, check=True, capture_output=True, text=True).stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error getting system: {e}", file=sys.stderr)
        sys.exit(1)

    targets_cmd = [
        "nix", "eval", "--json", "--impure",
        "--apply", "pkgs: import ./scripts/get-update-targets.nix { packages = pkgs; }",
        f".#packages.{system}",
    ]
    try:
        targets_json = subprocess.run(targets_cmd, check=True, capture_output=True, text=True).stdout
        return cast(list[UpdateTarget], json.loads(targets_json))
    except subprocess.CalledProcessError as e:
        print(f"Error getting targets: {e}", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(description="Update NUR packages using nix-update")
    parser.add_argument(
        "--build",
        action="store_true",
        help="Build each package after updating to verify it compiles (skips broken updates)",
    )
    args = parser.parse_args()

    targets = get_targets()
    failed: list[str] = []
    for target in targets:
        name = target["name"]
        use_update_script = target.get("useUpdateScript", False)
        extra_args = target.get("extraArgs", [])
        unfree = target.get("unfree", False)

        print(f"Updating {name}...")

        # Unfree packages can't be built via `--flake` (pure eval ignores
        # NIXPKGS_ALLOW_UNFREE), so use the default `--file default.nix` path
        # (impure channel eval honors it). Free packages use `--flake`.
        cmd: list[str] = ["nix", "shell", "nixpkgs#nix-update", "-c", "nix-update"]
        if not unfree:
            cmd.append("--flake")
        cmd.append(name)

        if use_update_script:
            cmd.append("--use-update-script")

        if args.build:
            cmd.append("--build")

        cmd.extend(extra_args)

        try:
            _ = subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Warning: Failed to update {name} (exit code {e.returncode})", file=sys.stderr)
            failed.append(name)

    if failed:
        print(f"\nFailed to update: {', '.join(failed)}", file=sys.stderr)


if __name__ == "__main__":
    main()
