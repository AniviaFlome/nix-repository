{
  lib,
  buildLua,
  fetchFromGitHub,
  ffmpeg,
  nix-update-script,
}:

buildLua {
  pname = "sub-seek";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "moonlight-mpv";
    rev = "abb438ae85d2620e3556f7cbc1ef677cdee86aaf";
    hash = "sha256-WcR+29DBSrrBs1tRUeBEcHWz02VJrdb2mRYp7MjNcqE=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 portable_config/scripts/sub-seek.lua $out/share/mpv/scripts/sub-seek.lua
    sed -i 's|^local FFMPEG = .*|local FFMPEG = "${lib.getExe ffmpeg}"|' \
      $out/share/mpv/scripts/sub-seek.lua
    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Fullscreen, clickable list of every subtitle line for mpv, with seeking on selection";
    homepage = "https://github.com/v-amorim/mpv";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
