{
  pkgs,
}:
{
  makeReleaseUpdater =
    {
      name,
      pname ? name,
      repo,
      versionFilter ? "sed 's/^v//'",
      # Optional tag prefix to select releases from a shared feed that
      # publishes multiple product lines (e.g. bottlesdevs/wine ships
      # soda-*, protosoda-*, caffe-*, ... from one releases endpoint).
      # When set, only tags starting with the prefix are considered.
      tagPrefix ? null,
    }:
    pkgs.writeScript "update-${name}" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq nix-update
      repo="${repo}"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)${
        if tagPrefix == null then "" else " | select(.tag_name | startswith(\"${tagPrefix}\"))"
      }) | .[0].tag_name' --raw-output | ${versionFilter})"
      if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Error: Failed to fetch version from $repo" >&2
        exit 1
      fi
      nix-update --flake --version="$version" ${pname}
      nix-update --flake --version=skip ${pname}
    '';
}
