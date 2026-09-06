{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-sync";
  version = "0-unstable-2026-09-06";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "2ddd496ae4052477bf468c7309ead8af8d7b40e6";
    hash = "sha256-qDz5rrgu6wMW88V/L1K68lHd6ICclt1VABdBzDbE1ts=";
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
