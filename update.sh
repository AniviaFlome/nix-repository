#!/usr/bin/env bash
set -e
nix flake update
nix shell nixpkgs#nix-update -c nix-update --flake whisper-subs
nix shell nixpkgs#nix-update -c nix-update --flake inter-subs
