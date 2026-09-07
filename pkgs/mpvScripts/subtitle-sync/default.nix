{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-sync";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "mpv-scripts";
    rev = "3a565368580f2998d4f04fe7420c2c8f8701f8d0";
    hash = "sha256-Vo+QkBIt2mDk8S1zd5WFPMi3rrwYSwRg+hiqcTN+BS8=";
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
