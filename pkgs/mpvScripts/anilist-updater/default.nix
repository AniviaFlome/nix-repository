{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  nix-update-script,
}:

buildLua {
  pname = "anilist-updater";
  version = "0-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "AzuredBlue";
    repo = "mpv-anilist-updater";
    rev = "ccf3ca53fca216e7b3b6fb0235e813601f470852";
    hash = "sha256-pTC3C8fnpuhNx/VMl/ChDO8M6Koot/94Nkw105rAjfo=";
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
