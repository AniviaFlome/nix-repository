{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  libGL,
  libX11,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
  libXrender,
  libXinerama,
  alsa-lib,
  libpulseaudio,
  udev,
  vulkan-loader,
  wayland,
  libxkbcommon,
  libudev-zero,
}:

let
  pname = "wizard101";
  version = "2026-05-11";

  src = fetchurl {
    url = "https://github.com/aniviaflome/nix-repository/releases/download/mirrored/wizard101-${version}";
    hash = "sha256-0hy8j2pahbb4jinv4cxpxlbzr777xmjrg1h93c05s0rw7ffwhyyw";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    libGL
    libX11
    libXcursor
    libXext
    libXi
    libXrandr
    libXrender
    libXinerama
    alsa-lib
    libpulseaudio
    udev
    libudev-zero
    vulkan-loader
    wayland
    libxkbcommon
  ];

  unpackPhase = "true";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/${pname}
    cp $src $out/opt/${pname}/wizard101
    chmod +x $out/opt/${pname}/wizard101

    makeWrapper $out/opt/${pname}/wizard101 $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL vulkan-loader wayland libxkbcommon ]}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "wizard101";
      exec = "wizard101";
      desktopName = "Wizard101";
      genericName = "Game";
      categories = [ "Game" ];
    })
  ];

  meta = with lib; {
    description = "Wizard101 MMO game";
    homepage = "https://www.wizard101.com";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wizard101";
  };
}
