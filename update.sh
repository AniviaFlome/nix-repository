#!/usr/bin/env bash
set -e

nix flake update

# Get release targets using Nix evaluation
targets=$(nix eval --json --impure --expr 'import ./get-update-targets.nix {}' | python3 -c "import sys, json; print('\n'.join(json.load(sys.stdin)))")

for package in $targets; do
  echo "Updating $package..."
  nix shell nixpkgs#nix-update -c nix-update --flake --version=branch "$package"
done
