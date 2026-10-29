{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "reset-all";
  version = "0-unstable-2026-10-28";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "moonlight-mpv";
    rev = "abb438ae85d2620e3556f7cbc1ef677cdee86aaf";
    hash = "sha256-WcR+29DBSrrBs1tRUeBEcHWz02VJrdb2mRYp7MjNcqE=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 portable_config/scripts/reset-all.lua $out/share/mpv/scripts/reset-all.lua
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Puts mpv playback back to a fresh-start state without reloading the file";
    homepage = "https://github.com/v-amorim/moonlight-mpv";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
