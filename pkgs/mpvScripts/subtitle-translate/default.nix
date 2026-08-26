{
  lib,
  buildLua,
  fetchFromGitHub,
  curl,
  ffmpeg,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-translate";
  version = "0-unstable-2026-08-26";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "59d04014ba3a163100d82a40a4ec659746d8b644";
    hash = "sha256-R9QYGjP0R1vmGeiBLTUygIXtg41ehrNb4K8Qp0YlIs8=";
  };

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
