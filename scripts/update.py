#!/usr/bin/env python3
import json
import subprocess
import sys
from typing import TypedDict, cast


class UpdateTarget(TypedDict):
    name: str
    useUpdateScript: bool
    extraArgs: list[str]


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
    targets = get_targets()
    failed: list[str] = []
    for target in targets:
        name = target["name"]
        extra_args = target["extraArgs"]

        print(f"Updating {name}...")

        cmd: list[str] = ["nix", "shell", "nixpkgs#nix-update", "-c", "nix-update", "--flake", name]

        if target["useUpdateScript"]:
            cmd.append("--use-update-script")

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
