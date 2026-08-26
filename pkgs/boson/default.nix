{
  lib,
  stdenvNoCC,
  fetchzip,
  electron,
  zstd,
  steamDisplayName ? "Boson",
  makeWrapper,
  nix-update,
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
  preferLocalBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out

    for f in $src/*; do
      name=$(basename "$f")
      if [[ "$name" != "compatibilitytool.vdf" ]]; then
        ln -s "$f" "$out/$name"
      fi
    done

    cp $src/compatibilitytool.vdf $out/compatibilitytool.vdf

    mkdir -p $out/electron
    ln -s ${electron}/bin/electron $out/electron/electron

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$out/compatibilitytool.vdf" \
      --replace-fail '"display_name" "Boson"' '"display_name" "${steamDisplayName}"'

    wrapProgram $out/boson \
      --set ELECTRON_PATH "${electron}/bin/electron" \
      --set GDK_BACKEND x11
  '';

  passthru = {
    electronPath = "${electron}/bin/electron";
    updateScript = [ nix-update ];
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
