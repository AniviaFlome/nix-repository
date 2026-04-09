{
  lib,
  stdenvNoCC,
  fetchzip,
  makeReleaseUpdater,
  electron,
  xdg-utils,
  makeWrapper,
  steamDisplayName ? "NativeCookie",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nativecookie-bin";
  version = "2.8";

  src = fetchzip {
    url = "https://github.com/Kesefon/NativeCookie/releases/download/v${finalAttrs.version}/nativecookie.tar.gz";
    hash = "sha256-Jx/eobxIOfPu+3/CdG+WdtCXBwRhfoFamhLjlY6wR/E=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    # Link all files except electron directory and compatibilitytool.vdf
    for f in $src/*; do
      name=$(basename "$f")
      if [[ "$name" != "electron" && "$name" != "compatibilitytool.vdf" ]]; then
        ln -s "$f" "$out/$name"
      fi
    done

    # Copy compatibilitytool.vdf so we can modify it
    cp $src/compatibilitytool.vdf $out/compatibilitytool.vdf

    # Set up electron symlinks - the binary expects electron at ./electron/electron or ./electron/cookie-electron
    mkdir -p $out/electron
    ln -s ${electron}/bin/electron $out/electron/electron
    ln -s ${electron}/bin/electron $out/electron/cookie-electron

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$out/compatibilitytool.vdf" \
      --replace-fail '"display_name" "NativeCookie"' '"display_name" "${steamDisplayName}"'

    # Wrap the binary to ensure xdg-utils is in PATH
    wrapProgram $out/nativecookie \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  passthru.updateScript = makeReleaseUpdater {
    name = "nativecookie-bin";
    repo = "https://api.github.com/repos/Kesefon/NativeCookie/releases";
  };

  meta = {
    description = ''
      Run Cookie Clicker Steam edition with native Electron on Linux.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/Kesefon/NativeCookie";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
