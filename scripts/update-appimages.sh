#!/usr/bin/env bash
set -euo pipefail

REPO="aniviaflome/nix-repository"
RELEASE_TAG="appimages"
DATE=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

WIZARD101_NIX="$REPO_ROOT/pkgs/wizard101/default.nix"
CRYSTAL_REALMS_NIX="$REPO_ROOT/pkgs/crystal-realms/default.nix"

WIZARD101_URL="https://www.wizard101.com/downloadGameChromebook"
CRYSTAL_REALMS_URL="https://crystalrealmsgame.com/builds/builds/linux_x86/crystal_realms_linux_x86.tar.gz"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

log() { echo "::group::$1" || echo "[*] $1"; }
log_end() { echo "::endgroup::" || true; }

fetch_current_hash() {
    local nix_file="$1"
    grep -oP 'hash\s*=\s*"\K[^"]+' "$nix_file" | head -1
}

fetch_current_version() {
    local nix_file="$1"
    grep -oP 'version\s*=\s*"\K[^"]+' "$nix_file" | head -1
}

update_nix_file() {
    local nix_file="$1"
    local new_version="$2"
    local new_hash="$3"

    sed -i "s|version = \"[^\"]*\"|version = \"${new_version}\"|" "$nix_file"
    sed -i "s|hash = \"[^\"]*\"|hash = \"${new_hash}\"|" "$nix_file"
}

ensure_release() {
    if ! gh release view "$RELEASE_TAG" --repo "$REPO" > /dev/null 2>&1; then
        gh release create "$RELEASE_TAG" --repo "$REPO" \
            --title "AppImage Mirror" \
            --notes "Mirrored game builds with date-stamped filenames to provide stable URLs for Nix."
    fi
}

delete_old_assets() {
    local prefix="$1"
    local assets
    assets=$(gh release view "$RELEASE_TAG" --repo "$REPO" --json assets --jq '.assets[].name' 2>/dev/null || true)
    for asset in $assets; do
        if [[ "$asset" == ${prefix}* ]]; then
            echo "  Deleting old asset: $asset"
            gh release delete-asset "$RELEASE_TAG" "$asset" --repo "$REPO" --yes
        fi
    done
}

UPLOAD_SOMETHING=false

# --- Wizard101 ---
log "Checking Wizard101"
echo "Downloading Wizard101 from upstream..."
curl -fSL --max-time 120 -o "$TMPDIR/wizard101.AppImage" "$WIZARD101_URL" || {
    echo "Warning: Failed to download Wizard101, skipping."
    log_end
}
if [ -f "$TMPDIR/wizard101.AppImage" ]; then
    NEW_HASH=$(sha256sum "$TMPDIR/wizard101.AppImage" | cut -d' ' -f1)
    NEW_NIX_HASH="sha256-$(nix hash convert --hash-algo sha256 --to nix32 "$NEW_HASH" 2>/dev/null || nix-hash --to-base32 --type sha256 "$NEW_HASH")"
    OLD_HASH=$(fetch_current_hash "$WIZARD101_NIX")

    if [ "$NEW_NIX_HASH" != "$OLD_HASH" ]; then
        echo "Wizard101 has changed! Updating..."
        ensure_release
        delete_old_assets "wizard101-"
        DATED_NAME="wizard101-${DATE}.AppImage"
        gh release upload "$RELEASE_TAG" "$TMPDIR/wizard101.AppImage#$DATED_NAME" --repo "$REPO"
        update_nix_file "$WIZARD101_NIX" "$DATE" "$NEW_NIX_HASH"
        UPLOAD_SOMETHING=true
        echo "Wizard101 updated to $DATE"
    else
        echo "Wizard101 unchanged."
    fi
fi
log_end

# --- Crystal Realms ---
log "Checking Crystal Realms"
echo "Downloading Crystal Realms from upstream..."
curl -fSL --max-time 120 -o "$TMPDIR/crystal_realms.tar.gz" "$CRYSTAL_REALMS_URL" || {
    echo "Warning: Failed to download Crystal Realms, skipping."
    log_end
}
if [ -f "$TMPDIR/crystal_realms.tar.gz" ]; then
    NEW_HASH=$(sha256sum "$TMPDIR/crystal_realms.tar.gz" | cut -d' ' -f1)
    NEW_NIX_HASH="sha256-$(nix hash convert --hash-algo sha256 --to nix32 "$NEW_HASH" 2>/dev/null || nix-hash --to-base32 --type sha256 "$NEW_HASH")"
    OLD_HASH=$(fetch_current_hash "$CRYSTAL_REALMS_NIX")

    if [ "$NEW_NIX_HASH" != "$OLD_HASH" ]; then
        echo "Crystal Realms has changed! Updating..."
        ensure_release
        delete_old_assets "crystal-realms-"
        DATED_NAME="crystal-realms-${DATE}.tar.gz"
        gh release upload "$RELEASE_TAG" "$TMPDIR/crystal_realms.tar.gz#$DATED_NAME" --repo "$REPO"
        update_nix_file "$CRYSTAL_REALMS_NIX" "$DATE" "$NEW_NIX_HASH"
        UPLOAD_SOMETHING=true
        echo "Crystal Realms updated to $DATE"
    else
        echo "Crystal Realms unchanged."
    fi
fi
log_end

if [ "$UPLOAD_SOMETHING" = true ]; then
    echo "Changes detected. Nix files updated."
    echo "::set-output name=updated::true"
    exit 0
else
    echo "No changes detected."
    echo "::set-output name=updated::false"
    exit 0
fi
