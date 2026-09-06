{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-file-browser";
  version = "0-unstable-2026-03-27";

  src = fetchFromGitHub {
    owner = "CogentRedTester";
    repo = "mpv-file-browser";
    rev = "e07ab168fbba24063cd81c9b6f3fb8b85d5fe24d";
    hash = "sha256-zCDBxsGC7THQ2k0qDkjOq4TZm4thI2yk57a3i9PRCAs=";
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
