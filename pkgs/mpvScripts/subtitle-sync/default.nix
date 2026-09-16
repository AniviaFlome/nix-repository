{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-sync";
  version = "0-unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "cfd12de702839e54963d0c846cae063e3837e669";
    hash = "sha256-FiC2Tb9h0NdTdbNgIkY/CZCet8om0hYFqY9Hc+h65zw=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 subtitle-sync/main.lua $out/share/mpv/scripts/subtitle-sync.lua
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "MPV script to mark subtitle start times and calculate the difference between them";
    homepage = "https://github.com/AniviaFlome/mpv-scripts";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
