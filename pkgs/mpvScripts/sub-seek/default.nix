{
  lib,
  buildLua,
  fetchFromGitHub,
  ffmpeg,
  nix-update-script,
}:

buildLua {
  pname = "sub-seek";
  version = "0-unstable-2026-09-05";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "80854b78d10a535338a4d0c5a8df2731afef5c30";
    hash = "sha256-M8kBOIbD+Epl/TG6wVEvU5x+IEbyAPXq9tbiR8q6azo=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 portable_config/scripts/sub-seek.lua $out/share/mpv/scripts/sub-seek.lua
    sed -i 's|^local FFMPEG = .*|local FFMPEG = "${lib.getExe ffmpeg}"|' \
      $out/share/mpv/scripts/sub-seek.lua
    runHook postInstall
  '';

  passthru = {
    updatePr = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Fullscreen, clickable list of every subtitle line for mpv, with seeking on selection";
    homepage = "https://github.com/v-amorim/mpv";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
