#!/usr/bin/env bash
set -euo pipefail

REPO="aniviaflome/nix-repository"
RELEASE_TAG="mirror"
DATE=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PACKAGES=(
  "wizard101|https://www.wizard101.com/downloadGameChromebook|pkgs/wizard101/default.nix"
  "crystal-realms|https://crystalrealmsgame.com/builds/builds/linux_x86/crystal_realms_linux_x86.tar.gz|pkgs/crystal-realms/default.nix"
)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

log() { echo "::group::$1" || echo "[*] $1"; }
log_end() { echo "::endgroup::" || true; }

fetch_current_hash() {
    local nix_file="$1"
    grep -oP 'hash\s*=\s*"\K[^"]+' "$nix_file" | head -1
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
            --title "Mirrored Builds" \
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

compute_nix_hash() {
    local file="$1"
    local hex
    hex=$(sha256sum "$file" | cut -d' ' -f1)
    nix hash convert --hash-algo sha256 --to nix32 "$hex" 2>/dev/null || nix-hash --to-base32 --type sha256 "$hex"
}

detect_ext() {
    local file="$1"
    local mime
    mime=$(file --brief --mime-type "$file" 2>/dev/null || echo "application/octet-stream")
    case "$mime" in
        application/x-appimage|application/x-iso9660-appimage) echo "" ;;
        application/gzip|application/x-gzip) echo ".tar.gz" ;;
        application/x-xz) echo ".tar.xz" ;;
        application/x-bzip2) echo ".tar.bz2" ;;
        application/zip) echo ".zip" ;;
        application/x-sharedlib) echo "" ;;
        application/x-executable) echo "" ;;
        *) echo "" ;;
    esac
}

UPDATED=false

for entry in "${PACKAGES[@]}"; do
    IFS='|' read -r name url nix_path <<< "$entry"
    nix_file="$REPO_ROOT/$nix_path"
    tmp_file="$TMPDIR/${name}"

    log "Checking $name"
    echo "Downloading $name from upstream..."
    if ! curl -fSL --max-time 120 -o "$tmp_file" "$url"; then
        echo "Warning: Failed to download $name, skipping."
        log_end
        continue
    fi

    ext=$(detect_ext "$tmp_file")
    NEW_NIX_HASH="sha256-$(compute_nix_hash "$tmp_file")"
    OLD_HASH=$(fetch_current_hash "$nix_file")

    if [ "$NEW_NIX_HASH" != "$OLD_HASH" ]; then
        echo "$name has changed! Updating..."
        ensure_release
        delete_old_assets "${name}-"
        dated_name="${name}-${DATE}${ext}"
        gh release upload "$RELEASE_TAG" "${tmp_file}#${dated_name}" --repo "$REPO"
        update_nix_file "$nix_file" "$DATE" "$NEW_NIX_HASH"
        UPDATED=true
        echo "$name updated to $DATE"
    else
        echo "$name unchanged."
    fi
    log_end
done

if [ "$UPDATED" = true ]; then
    echo "Changes detected. Nix files updated."
else
    echo "No changes detected."
fi
echo "updated=$UPDATED" >> "${GITHUB_OUTPUT:-/dev/null}"
