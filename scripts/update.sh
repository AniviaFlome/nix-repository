#!/usr/bin/env bash
set -e

# Get update targets using Nix evaluation
system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
targets_json=$(nix eval --json --impure --apply "pkgs: import ./scripts/get-update-targets.nix { packages = pkgs; }" ".#packages.${system}")

# Process each target
echo "$targets_json" | python3 -c "
import sys, json, subprocess

targets = json.load(sys.stdin)
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
"
