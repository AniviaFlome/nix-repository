{
  lib,
  buildLua,
  fetchzip,
  curl,
  ffmpeg,
  nix-update-script,
}:

buildLua (finalAttrs: {
  pname = "mpv-translate";
  version = "0.1.15-alpha.20";

  src = fetchzip {
    url = "https://github.com/mpv-easy/mpv-easy/releases/download/v${finalAttrs.version}/mpv-easy-translate.zip";
    hash = "sha256-EHx4BFx54sG8uJqO9dmBc4prota2jmgFBHnnfUcGifM=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    install -m644 $src/scripts/main.js $out/share/mpv/scripts/mpv-translate.js

    substituteInPlace $out/share/mpv/scripts/mpv-translate.js \
      --replace-fail '"ffmpeg"' '"${ffmpeg}/bin/ffmpeg"' \
      --replace-fail '"curl"' '"${curl}/bin/curl"'
    runHook postInstall
  '';

  passthru = {
    scriptName = "mpv-translate.js";
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Real-time subtitle translation for mpv";
    homepage = "https://github.com/mpv-easy/mpv-easy/tree/main/mpv-translate";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
