{
  lib,
  stdenv,
  fetchurl,
  python3,
  makeWrapper,
  binutils-unwrapped,
  gnutar,
  zstd,
  xdg-utils,
  curl,
  autoPatchelfHook,
  libglvnd,
  libxkbcommon,
  libdrm,
  mesa,
  fontconfig,
  freetype,
  glib,
  dbus,
  expat,
  zlib,
  openssl,
  wayland,
  xorg,
  nix-update-script,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.tkinter
    ps.cryptography
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bedrock-on-linux-unwrapped";
  version = "2.2.4";

  src = fetchurl {
    url = "https://github.com/Wyze3306/BedrockOnLinux/releases/download/v${finalAttrs.version}/bedrock-on-linux_${finalAttrs.version}_amd64.deb";
    hash = "sha256-YEErj6bmH4JVLd1fbged5UsC1bnBsZV5MDRyelLfcLM=";
  };

  nativeBuildInputs = [
    binutils-unwrapped
    gnutar
    zstd
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libglvnd
    libxkbcommon
    libdrm
    mesa
    fontconfig
    freetype
    glib
    dbus
    expat
    zlib
    openssl
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libxcb
    xorg.xcbutilcursor
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
  ];

  unpackPhase = ''
    ar x $src
    tar -xf data.tar.zst
  '';

  installPhase = ''
    libdir=$out/lib/bedrock-on-linux
    mkdir -p $libdir $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    cp -r usr/lib/bedrock-on-linux/. $libdir/

    # Drop optional Qt plugins whose extra libraries aren't worth pulling in
    # (sql backends, gtk3 theming, cups printing, headless eglfs/kms, ...).
    # The app is pure QtWidgets, so QML modules and bundled dev tools go too.
    qt=$libdir/PySide6/Qt
    rm -rf $qt/plugins/sqldrivers \
      $qt/plugins/qmltooling \
      $qt/plugins/wayland-graphics-integration-server \
      $qt/plugins/egldeviceintegrations \
      $qt/plugins/platforminputcontexts \
      $qt/plugins/platformthemes \
      $qt/plugins/printsupport \
      $qt/plugins/designer \
      $qt/plugins/imageformats/libqpdf.so \
      $qt/qml \
      $qt/bin

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/bedrock-on-linux \
      --set PYTHONPATH "$libdir" \
      --prefix PATH : "${
        lib.makeBinPath [
          curl
          gnutar
          zstd
          xdg-utils
        ]
      }" \
      --add-flags "$libdir/bedrock-on-linux"

    install -Dm644 usr/share/applications/bedrock-on-linux.desktop $out/share/applications/bedrock-on-linux.desktop
    install -Dm644 usr/share/icons/hicolor/256x256/apps/bedrock-on-linux.png $out/share/icons/hicolor/256x256/apps/bedrock-on-linux.png
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^v(\\d+\\.\\d+\\.\\d+)$" ];
  };

  meta = with lib; {
    description = "Run Minecraft Bedrock (Windows GDK) on Linux, multiplayer included";
    homepage = "https://github.com/Wyze3306/BedrockOnLinux";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "bedrock-on-linux";
    platforms = [ "x86_64-linux" ];
  };
})
