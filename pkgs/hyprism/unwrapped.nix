{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  nix-update-script,
  expat,
  fontconfig,
  freetype,
  glib,
  icu,
  libglvnd,
  libice,
  libsm,
  libx11,
  libxcomposite,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  libxtst,
  openssl,
  wayland,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hyprism-unwrapped";
  version = "4.0.0";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${finalAttrs.version}/Hyprism-linux-x64-${finalAttrs.version}.deb";
    hash = "sha256-Xpr3DyfuGxB/sfy4P/bwz8Bf5GJxETtvz1LwMQeTyxM=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  preferLocalBuild = true;

  buildInputs = [
    expat
    fontconfig
    freetype
    glib
    icu
    libglvnd
    libice
    libsm
    libx11
    libxcomposite
    libxcursor
    libxext
    libxi
    libxkbcommon
    libxrandr
    libxtst
    openssl
    stdenv.cc.cc.lib
    wayland
    zlib
  ];

  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/hyprism
    cp -r opt/hyprism/. $out/lib/hyprism/
    ln -s "Hyprism Launcher" $out/lib/hyprism/hyprism

    install -Dm644 usr/share/icons/hicolor/scalable/apps/io.github.hyprismteam.Hyprism.svg \
      $out/share/icons/hicolor/scalable/apps/hyprism.svg

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hytale launcher with mod management";
    homepage = "https://github.com/HyPrismTeam/HyPrism";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
