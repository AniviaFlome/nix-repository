{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-sync";
  version = "0-unstable-2025-12-26";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "417da706fafac5a1871c3238bb79fb78cdcac52f";
    hash = "sha256-trrFwqqcPIfr5ajyKhClu+r0LLNan1N4dXbmrOIToOA=";
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
