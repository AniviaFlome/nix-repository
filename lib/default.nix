{
  pkgs,
}:
with pkgs.lib;
{
  makeReleaseUpdater =
    {
      name,
      pname ? name,
      repo,
      versionFilter ? "sed 's/^v//'",
    }:
    pkgs.writeScript "update-${name}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="${repo}"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output | ${versionFilter})"
      if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Error: Failed to fetch version from $repo" >&2
        exit 1
      fi
      update-source-version ${pname} "$version"
    '';

  makeMirrorUpdater =
    {
      name,
      pname ? name,
      url,
      repo ? "aniviaflome/nix-repository",
      releaseTag ? "mirror",
      ext ? "",
    }:
    pkgs.writeScript "update-${name}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl common-updater-scripts
      set -euo pipefail

      url="${url}"
      repo="${repo}"
      tag="${releaseTag}"
      ext="${ext}"
      pname="${pname}"

      tmp=$(mktemp)
      trap 'rm -f "$tmp"' EXIT

      if ! curl -kfSL --max-time 120 -o "$tmp" "$url"; then
        echo "Error: Failed to download $url" >&2
        exit 1
      fi

      hex=$(sha256sum "$tmp" | cut -d' ' -f1)
      new_hash="sha256-$(nix hash convert --hash-algo sha256 --to nix32 "$hex")"
      date=$(date +%Y-%m-%d)

      if ! gh release view "$tag" --repo "$repo" >/dev/null 2>&1; then
        gh release create "$tag" --repo "$repo" \
          --title "Mirrored Builds" \
          --notes "Mirrored game builds with date-stamped filenames to provide stable URLs for Nix."
      fi

      dated_name="''${pname}-''${date}''${ext}"
      gh release upload "$tag" "''${tmp}#''${dated_name}" --repo "$repo" --clobber

      update-source-version "$pname" "$date" "$new_hash"
    '';
}
