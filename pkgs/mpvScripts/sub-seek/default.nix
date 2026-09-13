{
  lib,
  buildLua,
  fetchFromGitHub,
  ffmpeg,
  nix-update-script,
}:

buildLua {
  pname = "sub-seek";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "a6f3677037bcf6c28093926d3373915a2b4242ec";
    hash = "sha256-wEjrpN5KLVpnr4d3HmF2SAo8Kd4RENu21sDrV9heVgo=";
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
