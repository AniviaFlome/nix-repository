{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  vulkan-loader,
  nix-update-script,
}:
let
  pname = "openanime-bin";
  version = "1.0.5";

  src = fetchurl {
    url = "https://github.com/tuanapi/OpenAnime-Linux-Desktop-App/releases/download/v${version}/OpenAnime-${version}.AppImage";
    hash = "sha256-eUkKIuS/3Xn7WLaW31Phf5FyxEaeBiTsQonMfZU2u30=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.vulkan-loader ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/openanime.desktop $out/share/applications/openanime.desktop
    install -Dm444 ${appimageContents}/openanime.png $out/share/icons/hicolor/512x512/apps/openanime.png
    substituteInPlace $out/share/applications/openanime.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=openanime'
    
    # Rename binary from openanime-bin to openanime
    mv $out/bin/openanime-bin $out/bin/openanime
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
