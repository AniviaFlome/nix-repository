{
  lib,
  buildLua,
  fetchFromGitHub,
  curl,
  ffmpeg,
  tesseract,
  python3,
  nix-update-script,
  withTesseract ? true,
  withRapidocr ? false,
  withEasyocr ? false,
  withPaddleocr ? false,
}:

let
  pythonOCR = python3.withPackages (
    ps:
    with ps;
    lib.optional withRapidocr rapidocr-onnxruntime
    ++ lib.optional withEasyocr easyocr
    ++ lib.optional withPaddleocr paddleocr
  );
  withPythonOCR = withRapidocr || withEasyocr || withPaddleocr;
in
buildLua {
  pname = "subtitle-translate";
  version = "0-unstable-2026-09-08";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "0ae50e16e1e7c336c7a277f8630d7732dfb7d4d9";
    hash = "sha256-Xpy+SHoOOoOfox70Zo5iCWUxmBsbg1OBnHXQdTWmDxU=";
  };

  runtime-dependencies = lib.optional withTesseract tesseract ++ lib.optional withPythonOCR pythonOCR;

  installPhase = ''
    runHook preInstall
    install -Dm644 subtitle-translate/*.lua -t $out/share/mpv/scripts
    mv $out/share/mpv/scripts/main.lua $out/share/mpv/scripts/subtitle-translate.lua

    substituteInPlace $out/share/mpv/scripts/providers.lua \
      --replace-fail '"curl"' '"${curl}/bin/curl"'
    substituteInPlace $out/share/mpv/scripts/timeline.lua \
      --replace-fail '"sh", "-c", "command -v ffmpeg"' '"${ffmpeg}/bin/ffmpeg", "-version"' \
      --replace-fail 'tl.ffmpeg_path = (res and res.status == 0 and util.trim(res.stdout) ~= "") and util.trim(res.stdout) or nil' 'tl.ffmpeg_path = (res and res.status == 0) and "${ffmpeg}/bin/ffmpeg" or nil'
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "MPV script that translates subtitles on screen with dictionary popups";
    homepage = "https://github.com/AniviaFlome/mpv-scripts/tree/main/subtitle-translate";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
