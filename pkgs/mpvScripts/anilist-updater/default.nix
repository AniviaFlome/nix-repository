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
  version = "0-unstable-2026-09-26";

  src = fetchFromGitHub {
    owner = "AzuredBlue";
    repo = "mpv-anilist-updater";
    rev = "4d489d132b5db5d32a1dc3a4c4e51e6795fba689";
    hash = "sha256-vU7/CDlQ3sT5/zvFUr0ORzPQPqHRWnwmPtag8/VXdy8=";
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
