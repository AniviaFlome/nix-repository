{
  lib,
  appimageTools,
  fetchurl,
  nix-update-script,
}:

let
  pname = "game-sentence-miner-bin";
  version = "2026.4.4";

  src = fetchurl {
    url = "https://github.com/bpwhelan/GameSentenceMiner/releases/download/v${version}/GameSentenceMiner-${version}.AppImage";
    hash = "sha256-io8usbhaogp/cgcEiscEAmL+tTwuuMfj2gvPUIVuDtM=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

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
