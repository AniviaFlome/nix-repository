#!/usr/bin/env bash
set -e

# Get update targets using Nix evaluation
system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
targets_json=$(nix eval --json --impure --apply "pkgs: import ./scripts/get-update-targets.nix { packages = pkgs; }" ".#packages.${system}")

# Process each target
echo "$targets_json" | python3 ./scripts/update.py
