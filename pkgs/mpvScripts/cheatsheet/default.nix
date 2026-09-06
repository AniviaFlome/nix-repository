{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-cheatsheet";
  version = "0-unstable-2026-09-06";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "2ddd496ae4052477bf468c7309ead8af8d7b40e6";
    hash = "sha256-qDz5rrgu6wMW88V/L1K68lHd6ICclt1VABdBzDbE1ts=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 cheatsheet/main.lua $out/share/mpv/scripts/cheatsheet.lua
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "MPV cheatsheet script";
    homepage = "https://github.com/AniviaFlome/mpv-scripts/tree/main/cheatsheet";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
