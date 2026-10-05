{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

let
  python = python3.withPackages (
    ps: with ps; [
      guessit
      requests
    ]
  );
in
buildLua {
  pname = "anilist-updater";
  version = "0-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "AzuredBlue";
    repo = "mpv-anilist-updater";
    rev = "1a8cf143604ee56b26c2694bc6191451de45ae2e";
    hash = "sha256-EZsGK4nhkq+0aTFuDWC0rYOjIcm843OKrDRPDYQurhM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts/anilist-updater
    install -D -m644 main.lua $out/share/mpv/scripts/anilist-updater/main.lua
    install -D -m644 correction_overlay.lua $out/share/mpv/scripts/anilist-updater/correction_overlay.lua
    install -D -m644 anilistUpdater.py $out/share/mpv/scripts/anilist-updater/anilistUpdater.py

    substituteInPlace $out/share/mpv/scripts/anilist-updater/main.lua \
      --replace-fail 'return "python3"' 'return "${lib.getExe python}"'

    runHook postInstall
  '';

  passthru = {
    scriptName = "anilist-updater";
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Automatically updates your AniList based on the file you just watched";
    homepage = "https://github.com/AzuredBlue/mpv-anilist-updater";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
