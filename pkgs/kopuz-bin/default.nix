{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

let
  pname = "kopuz";
  version = "0.6.7";

  src = fetchurl {
    url = "https://github.com/Kopuz-org/kopuz/releases/download/v${version}/kopuz_${version}_x86_64.AppImage";
    hash = "sha256-rxWwt/8NuYvLAQT7F2lkrxQMyuecGnD9hZv4Mf4y4OA=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/kopuz.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/kopuz.png -t $out/share/icons/hicolor/256x256/apps/
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/440x440/apps/kopuz.png -t $out/share/icons/hicolor/440x440/apps/
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A modern music player for Jellyfin, Subsonic, and OpenSubsonic";
    homepage = "https://github.com/Kopuz-org/kopuz";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "kopuz";
  };
}
