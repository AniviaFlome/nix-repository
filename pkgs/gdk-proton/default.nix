{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  # Can be overridden to alter the display name in steam
  steamDisplayName ? "GDK-Proton",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gdk-proton";
  version = "10-29";

  src = fetchzip {
    url = "https://github.com/Weather-OS/GDK-Proton/releases/download/release${finalAttrs.version}/GDK-Proton${finalAttrs.version}.tar.gz";
    hash = "sha256-MtasTr8lXBY0vQlOPaXU94CO6O//l1qwAqFDbu5os+M=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true; # Do not cache this build

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    # Link all files except compatibilitytool.vdf (which we need to modify)
    for f in $src/*; do
      name=$(basename "$f")
      if [[ "$name" != "compatibilitytool.vdf" ]]; then
        ln -s "$f" "$out/$name"
      fi
    done

    # Copy compatibilitytool.vdf so we can modify it
    cp $src/compatibilitytool.vdf $out/compatibilitytool.vdf

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$out/compatibilitytool.vdf" \
      --replace-fail '"display_name" "GDK-Proton"' '"display_name" "${steamDisplayName}"'
  '';

  passthru = {
    updateScript = writeScript "update-gdk-proton" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="https://api.github.com/repos/Weather-OS/GDK-Proton/releases"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output | sed 's/^release//')"
      update-source-version gdk-proton "$version"
    '';
  };

  meta = {
    description = "GDK-Proton is a fork of Proton that includes the GDK (Game Development Kit) for Linux.";
    homepage = "https://github.com/Weather-OS/GDK-Proton";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
