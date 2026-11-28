{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-cheatsheet";
  version = "0-unstable-2026-11-27";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "0070e15673d9689d73ac139960d5a26211b89bc3";
    hash = "sha256-v0nZcNWcky7KDnNCpAUJdkb/FE2BIoa7i6dNu5F8I5M=";
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
