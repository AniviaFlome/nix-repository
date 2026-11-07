#!/usr/bin/env bash
set -euo pipefail

ATTR=browse
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"
PKG_DIR="pkgs/browse"

META="$(curl -fsSL https://registry.npmjs.org/@opencode%2Fbrowse/latest)"
TARBALL="$(jq -r .dist.tarball <<<"$META")"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

curl -fsSL "$TARBALL" -o "$WORK/pkg.tgz"
tar -xzf "$WORK/pkg.tgz" -C "$WORK" package/package.json

jq 'del(.devDependencies)' "$WORK/package/package.json" >"$WORK/package.json"
(cd "$WORK" && npm install --package-lock-only --ignore-scripts --no-audit --no-fund)
cp "$WORK/package-lock.json" "$PKG_DIR/package-lock.json"

nix-update --flake "$ATTR"
