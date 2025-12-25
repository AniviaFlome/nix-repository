#!/usr/bin/env bash
set -e

nix flake update

# Get update targets using Nix evaluation (returns JSON array of {name, extraArgs})
targets_json=$(nix eval --json --impure --expr 'import ./scripts/get-update-targets.nix {}')

# Process each target
echo "$targets_json" | python3 -c "
import sys, json, subprocess

targets = json.load(sys.stdin)
for target in targets:
    name = target['name']
    extra_args = target.get('extraArgs', [])
    
    print(f'Updating {name}...')
    cmd = ['nix', 'shell', 'nixpkgs#nix-update', '-c', 'nix-update', '--flake', name] + extra_args
    subprocess.run(cmd, check=True)
"
