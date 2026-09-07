{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-cheatsheet";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "3a565368580f2998d4f04fe7420c2c8f8701f8d0";
    hash = "sha256-Vo+QkBIt2mDk8S1zd5WFPMi3rrwYSwRg+hiqcTN+BS8=";
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
