{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-file-browser";
  version = "0-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "CogentRedTester";
    repo = "mpv-file-browser";
    rev = "355c0a615159eb7315f96387ed6f31e30a285fb0";
    hash = "sha256-sN2qOpBgoirlyfr3ENESzsWl1lbaYT80tNUpsDFrAN8=";
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
