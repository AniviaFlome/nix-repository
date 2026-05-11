{
  lib,
  stdenv,
  autoPatchelfHook,
  libGL,
  libX11,
  libXcursor,
  libXrandr,
  libXinerama,
  libXi,
  libXext,
  libXxf86vm,
  alsa-lib,
  libpulseaudio,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  pname = "crystal-realms";
  version = "unstable";

  src = builtins.fetchTarball {
    url = "https://crystalrealmsgame.com/builds/builds/linux_x86/crystal_realms_linux_x86.tar.gz";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    libGL
    libX11
    libXcursor
    libXrandr
    libXinerama
    libXi
    libXext
    libXxf86vm
    alsa-lib
    libpulseaudio
    stdenv.cc.cc.lib
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "crystal-realms";
      exec = "crystal-realms";
      desktopName = "Crystal Realms";
      genericName = "2D Sandbox MMO";
      categories = [
        "Game"
        "ActionGame"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/${pname} $out/bin

    cp crystal_realms $out/opt/${pname}/
    cp -r assets $out/opt/${pname}/
    cp -r credits $out/opt/${pname}/ || true

    chmod +x $out/opt/${pname}/crystal_realms

    makeWrapper $out/opt/${pname}/crystal_realms $out/bin/crystal-realms \
      --chdir $out/opt/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A 2D sandbox MMO where players build worlds, craft items, and explore together";
    homepage = "https://crystalrealmsgame.com";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "crystal-realms";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
