{ pkgs }:

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
      update-source-version ${pname} "$version"
    '';
}
