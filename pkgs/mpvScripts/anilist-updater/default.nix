{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

buildLua {
  pname = "anilist-updater";
  version = "1.0.2-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "AzuredBlue";
    repo = "mpv-anilist-updater";
    rev = "3190b4db04f67f446624bd16bf8b436daf02192a";
    hash = "sha256-WimJT+gr24KHoAh9PCWtSckeZUkfjnhYviM5jiTjzVA=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts/anilist-updater/lua
    mkdir -p $out/share/mpv/scripts/anilist-updater/anilist_updater
    install -m644 main.lua anilistUpdater.py -t $out/share/mpv/scripts/anilist-updater/
    install -m644 lua/*.lua -t $out/share/mpv/scripts/anilist-updater/lua/
    install -m644 anilist_updater/*.py -t $out/share/mpv/scripts/anilist-updater/anilist_updater/

    substituteInPlace $out/share/mpv/scripts/anilist-updater/lua/backend.lua \
      --replace-fail '"python3"' '"${lib.getExe python3}"'

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
