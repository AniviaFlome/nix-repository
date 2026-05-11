{
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  perl,
  python3,
  openssl,
  glib,
  gtk3,
  gdk-pixbuf,
  pango,
  vte,
  freetype,
  fontconfig,
  libGL,
  libX11,
  libXcomposite,
  libXcursor,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  libxslt,
  libxml2,
  libpng,
  libpulseaudio,
  alsa-lib,
  cups,
  dbus,
  gnutls,
  vulkan-loader,
  libXxf86vm,
  gst_all_1,
  udev,
  sane-backends,
  nssmdns,
}:

let
  pname = "wizard101";
  version = "1.26-1";

  src =
    builtins.fetchurl "https://www.wizard101.com/downloadGameChromebook";
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  # Match the runtime deps from the .deb's install-wizard101.sh
  buildInputs = [
    perl
    python3
    openssl
    glib
    gtk3
    gdk-pixbuf
    pango
    vte
    freetype
    fontconfig
    libGL
    libX11
    libXcomposite
    libXcursor
    libXext
    libXfixes
    libXi
    libXinerama
    libXrandr
    libXrender
    libxslt
    libxml2
    libpng
    libpulseaudio
    alsa-lib
    cups
    dbus
    gnutls
    vulkan-loader
    libXxf86vm
    udev
    sane-backends
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wizard101";
      exec = "wizard101";
      desktopName = "Wizard101";
      genericName = "Free-to-play MMO Wizards game";
      icon = "wizard101";
      categories = [
        "Game"
        "RolePlaying"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r opt/wizard101 $out/opt/wizard101

    # Symlink wineserver
    if [ -f "$out/opt/wizard101/bin/wineserver64" ]; then
      ln -sf wineserver64 $out/opt/wizard101/bin/wineserver
    elif [ -f "$out/opt/wizard101/bin/wineserver32" ]; then
      ln -sf wineserver32 $out/opt/wizard101/bin/wineserver
    fi

    mkdir -p $out/bin
    makeWrapper $out/opt/wizard101/bin/cxbottle $out/bin/wizard101 \
      --set CX_ROOT $out/opt/wizard101 \
      --prefix PATH : ${lib.makeBinPath [ perl python3 openssl ]} \
      --prefix PERL5LIB : $out/opt/wizard101/lib/perl \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libGL
        libX11
        libXcomposite
        libXcursor
        libXext
        libXfixes
        libXi
        libXinerama
        libXrandr
        libXrender
        libxslt
        libxml2
        libpng
        libpulseaudio
        alsa-lib
        cups
        dbus
        gnutls
        vulkan-loader
        libXxf86vm
        freetype
        fontconfig
        udev
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
      ]}:$out/opt/wizard101/lib

    # Install icon if available
    if [ -f "$out/opt/wizard101/share/icons/256x256/crossover.png" ]; then
      install -Dm644 "$out/opt/wizard101/share/icons/256x256/crossover.png" \
        "$out/share/icons/hicolor/256x256/apps/wizard101.png"
    fi

    runHook postInstall
  '';

  # Don't strip Wine binaries
  dontStrip = true;

  meta = with lib; {
    description = "Free-to-play MMO Wizards game (Chromebook/Linux version via CrossOver)";
    homepage = "https://www.wizard101.com";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wizard101";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
