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
      #!nix-shell -i bash -p curl jq nix-update
      repo="${repo}"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output | ${versionFilter})"
      if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Error: Failed to fetch version from $repo" >&2
        exit 1
      fi
      nix-update --flake --version="$version" ${pname}
      nix-update --flake --version=skip ${pname}
    '';
}
