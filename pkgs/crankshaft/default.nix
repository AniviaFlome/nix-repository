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
    url = "https://github.com/KraXen72/crankshaft/releases/download/${version}/crankshaft-portable-linux-x86_64.AppImage";
    sha256 = "sha256-sLX0v1WOotHmnA4TPN8JKtE6xoQqqbKBai9/BYBmwgY=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/crankshaft.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/0x0/apps/crankshaft.png $out/share/icons/hicolor/512x512/apps/crankshaft.png
    substituteInPlace $out/share/applications/crankshaft.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=crankshaft'
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
