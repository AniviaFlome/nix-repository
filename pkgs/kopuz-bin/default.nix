{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  nix-update-script,

  webkitgtk_4_1,
  gtk3,
  glib,
  libsoup_3,
  openssl,
  cairo,
  pango,
  gdk-pixbuf,
  harfbuzz,
  atk,
  at-spi2-atk,
  libX11,
  libXfixes,
  libXtst,
  libXinerama,
  libxkbcommon,
  wayland,
  libepoxy,
  xdotool,
  alsa-lib,
  librsvg,
  dbus,
  gst_all_1,
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
stdenv.mkDerivation {
  inherit pname version;

  src = appimageContents;

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    glib
    libsoup_3
    openssl
    cairo
    pango
    gdk-pixbuf
    harfbuzz
    atk
    at-spi2-atk
    libX11
    libXfixes
    libXtst
    libXinerama
    libxkbcommon
    wayland
    libepoxy
    xdotool
    alsa-lib
    librsvg
    dbus
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 ${appimageContents}/usr/bin/kopuz $out/bin/kopuz

    install -Dm644 ${appimageContents}/usr/share/applications/kopuz.desktop $out/share/applications/kopuz.desktop

    for size in 256 827; do
      install -Dm644 ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/kopuz.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/kopuz.png
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A modern, lightweight music player built with Rust and Dioxus";
    homepage = "https://github.com/Kopuz-org/kopuz";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "kopuz";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
