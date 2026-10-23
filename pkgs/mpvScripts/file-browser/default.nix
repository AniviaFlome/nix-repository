{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-file-browser";
  version = "0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "CogentRedTester";
    repo = "mpv-file-browser";
    rev = "721ee1cec74ef1c9439e3ceb0197ce3b88a103e3";
    hash = "sha256-K9oP9GGlhqiXt1GnG4HrLK25VnZw8w7mWAZuxD0vHjs=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts/file-browser
    cp -r main.lua modules $out/share/mpv/scripts/file-browser/
    runHook postInstall
  '';

  passthru = {
    scriptName = "file-browser";
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "A simple no-dependency file browser for mpv player";
    homepage = "https://github.com/CogentRedTester/mpv-file-browser";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
