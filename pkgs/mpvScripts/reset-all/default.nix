{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "reset-all";
  version = "0-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "moonlight-mpv";
    rev = "1d78c2f42ae0a4db021ce27f843d0e2dc1f92dd9";
    hash = "sha256-dRhL2BeNOeihgmpgN5kTtEr9JPDU66JH/mrQauYzV/0=";
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
