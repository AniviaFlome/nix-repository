{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-cheatsheet";
  version = "0-unstable-2025-02-08";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "be59f8b4be46ed931e72ccf65cc3a2ea1852fcf4";
    hash = "sha256-AtIaCuxEE18rKlcm6/NqxHu+XSLOysWm+eSuYi11/p8=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 cheatsheet/main.lua $out/share/mpv/scripts/cheatsheet.lua
    runHook postInstall
  '';

  passthru = {
    scriptName = "cheatsheet.lua";
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "MPV cheatsheet script";
    homepage = "https://github.com/AniviaFlome/mpv-scripts/tree/main/cheatsheet";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
