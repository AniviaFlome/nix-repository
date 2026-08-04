{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

let
  pname = "crankshaft";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/KraXen72/crankshaft/releases/download/${version}/crankshaft-x64.AppImage";
    hash = "sha256-BoqicNpINhWecnP6eIOZE3j6p2xdy+J8CTEHG2CfptE=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/crankshaft.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/512x512/apps/crankshaft.png $out/share/icons/hicolor/512x512/apps/crankshaft.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A fast, feature-rich krunker client written in typescript";
    homepage = "https://github.com/KraXen72/crankshaft";
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "crankshaft";
  };
}
