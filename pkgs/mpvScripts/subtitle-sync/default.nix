{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-sync";
  version = "unstable-2025-12-05";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "ae581c4591a77ada96d7bc36762038b938730b90";
    hash = "sha256-lyYoHPbQu7HpSKZ6hZFZ85FyT4IYajYoLEcDBk4Fmz0=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 subtitle-sync/main.lua $out/share/mpv/scripts/subtitle-sync.lua
    runHook postInstall
  '';

  passthru = {
    scriptName = "subtitle-sync.lua";
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "MPV script to mark subtitle start times and calculate the difference between them";
    homepage = "https://github.com/AniviaFlome/mpv-scripts";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
