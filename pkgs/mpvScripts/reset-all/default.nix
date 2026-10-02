{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "reset-all";
  version = "0-unstable-2026-09-21";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "moonlight-mpv";
    rev = "f5fbb67aac64b8367250c358a00444c7197fa38b";
    hash = "sha256-edPmI9SzAwKLQk4LjihZVZ9qx9V3FVq6F906Z7OvJE4=";
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
