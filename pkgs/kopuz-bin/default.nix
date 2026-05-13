{
  lib,
  fetchurl,
  appimageTools,
  webkitgtk_4_1,
  gtk3,
  nix-update-script,
}:

let
  pname = "kopuz-bin";
  version = "0.5.5";

  src = fetchurl {
    url = "https://github.com/Kopuz-org/kopuz/releases/download/v${version}/kopuz_${version}_x86_64.AppImage";
    hash = "sha256-e0WIs/2RlFOgAjMG6CcCEMjTFalNvxgKEUtBEbrtwt0=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = _pkgs: [
    webkitgtk_4_1
    gtk3
  ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/kopuz.desktop $out/share/applications/kopuz.desktop
    cp -r ${appimageContents}/usr/share/icons $out/share
    substituteInPlace $out/share/applications/kopuz.desktop \
      --replace-warn 'Exec=kopuz' "Exec=$out/bin/${pname}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A modern, lightweight music player built with Rust and Dioxus";
    homepage = "https://github.com/Kopuz-org/kopuz";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "kopuz-bin";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
