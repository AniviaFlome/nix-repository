{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  electron,
  zstd,
  # Can be overridden to alter the display name in steam
  steamDisplayName ? "Boson",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "boson";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/FyraLabs/boson/releases/download/v${finalAttrs.version}/boson-${finalAttrs.version}-x86_64-musl.tar.zst";
    hash = "sha256-1muEpuwVm0tRJirWTc2zIo2mE0lrhXUf74XLhUmkdnk=";
    nativeBuildInputs = [ zstd ];
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir -p $steamcompattool

    # Link all files except compatibilitytool.vdf (which we need to modify)
    for f in $src/*; do
      name=$(basename "$f")
      if [[ "$name" != "compatibilitytool.vdf" ]]; then
        ln -s "$f" "$steamcompattool/$name"
      fi
    done

    # Copy compatibilitytool.vdf so we can modify it
    cp $src/compatibilitytool.vdf $steamcompattool/compatibilitytool.vdf

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail '"display_name" "Boson"' '"display_name" "${steamDisplayName}"'
  '';

  passthru = {
    # Provide the electron path for use in Steam launch options
    # Usage: ELECTRON_PATH=${boson.electronPath} %command%
    electronPath = "${electron}/bin/electron";

    updateScript = writeScript "update-boson" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="https://api.github.com/repos/FyraLabs/boson/releases"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output | sed 's/^v//')"
      update-source-version boson "$version"
    '';
  };

  meta = {
    description = ''
      Run Electron Steam games natively on Linux.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)

      Note: Set ELECTRON_PATH in Steam launch options: ELECTRON_PATH=${electron}/bin/electron %command%
    '';
    homepage = "https://github.com/FyraLabs/boson";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
