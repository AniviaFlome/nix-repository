{
  lib,
  buildLua,
  fetchFromGitHub,
  ffmpeg,
  nix-update-script,
}:

buildLua {
  pname = "sub-seek";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "d0188f3d1298744f4f9cda15a00f97b8513b8702";
    hash = "sha256-cnv1wWYx5ZcYcKinwa4FWcReRjvnMJshSsMZwIsL/E0=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 portable_config/scripts/sub-seek.lua $out/share/mpv/scripts/sub-seek.lua
    sed -i 's|^local FFMPEG = .*|local FFMPEG = "${lib.getExe ffmpeg}"|' \
      $out/share/mpv/scripts/sub-seek.lua
    runHook postInstall
  '';

  passthru = {
    updatePr = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Fullscreen, clickable list of every subtitle line for mpv, with seeking on selection";
    homepage = "https://github.com/v-amorim/mpv";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
