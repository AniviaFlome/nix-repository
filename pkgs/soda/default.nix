{
  lib,
  stdenvNoCC,
  fetchzip,
  makeReleaseUpdater,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "soda";
  version = "11.0-10";

  src = fetchzip {
    url = "https://github.com/bottlesdevs/wine/releases/download/soda-${finalAttrs.version}/soda-${finalAttrs.version}-x86_64.tar.xz";
    hash = "sha256-Z1YGG58lRDmeJ9xGf7MCAGKwFnJALdRNALt3l502eTI=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for f in $src/*; do
      ln -s "$f" "$out/$(basename "$f")"
    done

    runHook postInstall
  '';

  passthru.updateScript = makeReleaseUpdater {
    name = "soda";
    repo = "https://api.github.com/repos/bottlesdevs/wine/releases";
    versionFilter = "sed 's/^soda-//'";
    tagPrefix = "soda-";
  };

  meta = {
    description = "Prebuilt Soda Wine runner for Bottles (Valve Wine with Proton, TKG and GE patches)";
    homepage = "https://github.com/bottlesdevs/wine";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    mainProgram = "wine";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
