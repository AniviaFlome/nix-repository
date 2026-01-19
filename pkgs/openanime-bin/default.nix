{
  lib,
  appimageTools,
  fetchurl,
  nix-update-script,
}:
let
  pname = "openanime-bin";
  version = "1.0.5";

  src = fetchurl {
    url = "https://github.com/tuanapi/OpenAnime-Linux-Desktop-App/releases/download/v${version}/OpenAnime-${version}.AppImage";
    hash = "sha256-J9CMq/y3E07MsSfJMzdizCMF02eMC10RnmQVUM+4wws=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/openanime.desktop $out/share/applications/openanime.desktop
    install -Dm444 ${appimageContents}/openanime.png $out/share/icons/hicolor/512x512/apps/openanime.png
    substituteInPlace $out/share/applications/openanime.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=openanime'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Resmi olmayan OpenAnime Linux istemcisi - WebGPU/Vulkan destekli";
    homepage = "https://github.com/tuanapi/OpenAnime-Linux-Desktop-App";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "openanime";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
