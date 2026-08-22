{
  lib,
  buildLua,
  fetchFromGitHub,
  crow-translate,
  nix-update-script,
}:

buildLua {
  pname = "subtitle-translate-mpv";
  version = "0-unstable-2026-01-13";

  src = fetchFromGitHub {
    owner = "EnergoStalin";
    repo = "subtitle-translate-mpv";
    rev = "f6c557a136c2f6e8612599efa4708e9daf0a7550";
    hash = "sha256-JcPrNgRA81eyqKkPfSK6/tDuUcZUEVRgSh4EmE3/bxU=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts/subtitle-translate-mpv
    cp -r . $out/share/mpv/scripts/subtitle-translate-mpv/
    rm -rf \
      $out/share/mpv/scripts/subtitle-translate-mpv/.github \
      $out/share/mpv/scripts/subtitle-translate-mpv/.editorconfig \
      $out/share/mpv/scripts/subtitle-translate-mpv/.gitignore \
      $out/share/mpv/scripts/subtitle-translate-mpv/.nvim.lua

    substituteInPlace $out/share/mpv/scripts/subtitle-translate-mpv/options.lua \
      --replace-fail "'Console-Translate'" "'crow'"
    substituteInPlace $out/share/mpv/scripts/subtitle-translate-mpv/modules/translators/crow.lua \
      --replace-fail "'crow'," "'${crow-translate}/bin/crow',"
    runHook postInstall
  '';

  passthru = {
    scriptName = "subtitle-translate-mpv";
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Modular mpv script for auto translating subtitles on the fly into multiple languages";
    homepage = "https://github.com/EnergoStalin/subtitle-translate-mpv";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
  };
}
