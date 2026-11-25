{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

buildLua {
  pname = "anilist-updater";
  version = "1.0.3-unstable-2026-11-23";

  src = fetchFromGitHub {
    owner = "AzuredBlue";
    repo = "mpv-anilist-updater";
    rev = "87b6859e4ad4d2b6494feb92971a93fd66abdcf2";
    hash = "sha256-QMwblXcPu69jOnL2ojtofRPJHtVgkVQCzZYkvfS9jic=";
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
