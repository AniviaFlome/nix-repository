{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  nix-update-script,
  libsndfile,
  portaudio,
  ffmpeg,
  libffi,
  xz,
  sqlite,
  libwebp,
}:

let
  pname = "game-sentence-miner-bin";
  version = "2026.4.7";

  src = fetchurl {
    url = "https://github.com/bpwhelan/GameSentenceMiner/releases/download/v${version}/GameSentenceMiner-${version}.AppImage";
    hash = "sha256-a40trq2vb0k7mpgWu69MHWkna+3mK2r67TltTqNQmWI=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _: [
    stdenv.cc.cc.lib
    libsndfile
    portaudio
    ffmpeg
    libffi
    xz
    sqlite
    libwebp
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A tool for sentence mining Japanese from video games";
    homepage = "https://github.com/bpwhelan/GameSentenceMiner";
    license = licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "game-sentence-miner-bin";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
