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
  libudev-zero,
  vulkan-loader,
  wayland,
  libxkbcommon,
}:

let
  pname = "crystal-realms";
  version = "1970-01-01";

  src = fetchurl {
    url = "https://github.com/aniviaflome/nix-repository/releases/download/mirrored/crystal-realms-${version}.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/${pname}
    cp -r * $out/opt/${pname}/

    binary=$(find $out/opt/${pname} -maxdepth 1 -type f -executable ! -name '*.sh' | head -1)
    if [ -z "$binary" ]; then
      binary=$(find $out/opt/${pname} -maxdepth 2 -type f -executable | head -1)
    fi

    makeWrapper "$binary" $out/bin/${pname} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL vulkan-loader wayland libxkbcommon ]}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "crystal-realms";
      exec = "crystal-realms";
      desktopName = "Crystal Realms";
      genericName = "Game";
      categories = [ "Game" ];
    })
  ];

  meta = with lib; {
    description = "Crystal Realms game";
    homepage = "https://crystalrealmsgame.com";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "crystal-realms";
  };
}
