{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

let
  pname = "nuvio";
  version = "0.1.31-alpha";

  src = fetchurl {
    url = "https://github.com/NuvioMedia/NuvioDesktop/releases/download/${version}/Nuvio-Linux-x86_64-${version}.AppImage";
    hash = "sha256-8J4nCBg7jgoLbcKLFQDePPtpayMnOPsiYeOCfcKPD7I=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Player bridge needs libmpv + WebKitGTK (proven by UnsatisfiedLinkError
  # at startup without them); Mesa provides DRI drivers so real GPUs get
  # hardware GL instead of Skiko's software fallback.
  extraPkgs = pkgs: [
    pkgs.mpv-unwrapped
    pkgs.webkitgtk_4_1
    pkgs.mesa
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/Nuvio.desktop $out/share/applications/nuvio.desktop
    substituteInPlace $out/share/applications/nuvio.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=nuvio' \
      --replace-warn 'Icon=Nuvio' 'Icon=nuvio'
    install -m 444 -D ${appimageContents}/Nuvio.png $out/share/icons/hicolor/512x512/apps/nuvio.png
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Free, open-source media streaming app";
    homepage = "https://github.com/NuvioMedia/NuvioDesktop";
    changelog = "https://github.com/NuvioMedia/NuvioDesktop/releases/tag/${version}";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "nuvio";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
