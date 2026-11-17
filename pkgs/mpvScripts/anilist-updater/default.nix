{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

buildLua {
  pname = "anilist-updater";
  version = "1.0.1-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "AzuredBlue";
    repo = "mpv-anilist-updater";
    rev = "6adfa490896014ea54a05e100bef72607d746663";
    hash = "sha256-Rfc5obzQJtXoJzwDAZgWymHD8BEthSSdmW6xS/w6PgU=";
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
