#!/usr/bin/env python3
import json
import subprocess
import sys

def get_targets():
    """Gets update targets using Nix evaluation."""
    # Get the current system
    system_cmd = ['nix', 'eval', '--impure', '--raw', '--expr', 'builtins.currentSystem']
    try:
        system = subprocess.run(system_cmd, check=True, capture_output=True, text=True).stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error getting system: {e}", file=sys.stderr)
        sys.exit(1)

    # Get targets for the system
    targets_cmd = [
        'nix', 'eval', '--json', '--impure',
        '--apply', 'pkgs: import ./scripts/get-update-targets.nix { packages = pkgs; }',
        f'.#packages.{system}'
    ]
    try:
        targets_json = subprocess.run(targets_cmd, check=True, capture_output=True, text=True).stdout
        return json.loads(targets_json)
    except subprocess.CalledProcessError as e:
        print(f"Error getting targets: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    targets = get_targets()
    for target in targets:
        name = target['name']
        extra_args = target.get('extraArgs', [])

        print(f'Updating {name}...')

        cmd = ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', name]

        # Use package's custom updateScript if it has one
        if target.get('useUpdateScript', False):
            cmd.append('--use-update-script')

        cmd.extend(extra_args)
        subprocess.run(cmd, check=True)

if __name__ == '__main__':
    main()
