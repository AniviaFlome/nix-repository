{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-cheatsheet";
  version = "0-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "0f8ff4e389eeb9eab52318844eb1752e15741bb2";
    hash = "sha256-nSsv1XKeLVaTi7mSItuSvhkqvtUB8Pms/rMpkPrrUVc=";
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
