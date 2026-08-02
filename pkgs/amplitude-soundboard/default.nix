{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

let
  pname = "amplitude-soundboard";
  version = "2.13.1";

  src = fetchurl {
    url = "https://github.com/dan0v/AmplitudeSoundboard/releases/download/${version}/Amplitude_Soundboard-x86_64.AppImage";
    hash = "sha256-+lsw+ViFCaVayEdnha3+50/B/d3UwBisaghP6vkMEF8=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.icu ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/amplitude_soundboard.desktop $out/share/applications/amplitude_soundboard.desktop
    install -Dm444 ${appimageContents}/icn.png $out/share/icons/hicolor/512x512/apps/icn.png
    substituteInPlace $out/share/applications/amplitude_soundboard.desktop \
      --replace-warn 'Exec=amplitude_soundboard' 'Exec=${pname}'
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A sleek, cross-platform soundboard";
    homepage = "https://github.com/dan0v/AmplitudeSoundboard";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "amplitude-soundboard";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
