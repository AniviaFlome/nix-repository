{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osu-beatmap-manager";
  version = "0.2.0";

  src = fetchzip {
    url = "https://github.com/AniviaFlome/osu-beatmap-manager/releases/download/v${finalAttrs.version}/obm-v${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-yWxmJaBLkhV/YIbpgL/9e8v6j3GXorLGKOEvlRwHqsk=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 obm $out/bin/obm

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "osu! Beatmap Manager";
    homepage = "https://github.com/AniviaFlome/osu-beatmap-manager";
    changelog = "https://github.com/AniviaFlome/osu-beatmap-manager/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "obm";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
