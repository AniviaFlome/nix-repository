{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

let
  pname = "crankshaft";
  version = "1.11.1";

  src = fetchurl {
    url = "https://github.com/KraXen72/crankshaft/releases/download/${version}/crankshaft-portable-linux-x86_64.AppImage";
    sha256 = "10yjq2ps8f040vhdmvk348041fyg7g81189jkppc74i46f5kh4hk";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/crankshaft.desktop -t $out/share/applications/
    cp -r ${appimageContents}/usr/share/icons $out/share/
    substituteInPlace $out/share/applications/crankshaft.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=crankshaft'
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A fast, feature-rich krunker client written in typescript";
    homepage = "https://github.com/KraXen72/crankshaft";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    mainProgram = "crankshaft";
  };
}
