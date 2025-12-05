#!/usr/bin/env bash
set -e
nix flake update
for package in $(ls packages); do
  nix shell nixpkgs#nix-update -c nix-update --flake $package
done
