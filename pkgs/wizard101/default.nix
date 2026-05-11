{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "wizard101";
  version = "1970-01-01";

  src = fetchurl {
    url = "https://github.com/aniviaflome/nix-repository/releases/download/appimages/wizard101-${version}.AppImage";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/*.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/*/apps/*.png -t $out/share/icons/hicolor/512x512/apps/ 2>/dev/null || true
    substituteInPlace $out/share/applications/*.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=wizard101' || true
  '';

  meta = with lib; {
    description = "Wizard101 MMO game";
    homepage = "https://www.wizard101.com";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wizard101";
  };
}
