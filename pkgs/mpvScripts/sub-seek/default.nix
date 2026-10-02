{
  lib,
  buildLua,
  fetchFromGitHub,
  ffmpeg,
  nix-update-script,
}:

buildLua {
  pname = "sub-seek";
  version = "0-unstable-2026-09-21";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "f5fbb67aac64b8367250c358a00444c7197fa38b";
    hash = "sha256-edPmI9SzAwKLQk4LjihZVZ9qx9V3FVq6F906Z7OvJE4=";
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
