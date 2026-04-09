{
  lib,
  stdenvNoCC,
  fetchzip,
  makeReleaseUpdater,
  # Can be overridden to alter the display name in steam
  steamDisplayName ? "GDK-Proton",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gdk-proton-bin";
  version = "10-32";

  src = fetchzip {
    url = "https://github.com/Weather-OS/GDK-Proton/releases/download/release${finalAttrs.version}/GDK-Proton${finalAttrs.version}.tar.gz";
    hash = "sha256-x6LuikI5/hdl6+Y0llTYLDJbX+flma1wJSrJYHxyYQ0=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

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
      --replace-warn "GE-Proton${finalAttrs.version}" "${steamDisplayName}"
  '';

  passthru = {
    updateScript = makeReleaseUpdater {
      name = "gdk-proton-bin";
      repo = "https://api.github.com/repos/Weather-OS/GDK-Proton/releases";
      versionFilter = "sed 's/^release//'";
    };
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
