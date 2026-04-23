{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  nix-update-script,
  gtk3,
  libepoxy,
  wayland,
  libxkbcommon,
  mpv,
  copyDesktopItems,
  makeDesktopItem,
  libX11,
  libXrandr,
  libXrender,
  libXinerama,
  libXcursor,
  libXext,
  libXi,
  libXfixes,
}:

let
  pname = "bloomeetunes-bin";
  version = "3.0.1+199";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://github.com/HemantKArya/BloomeeTunes/releases/download/v${version}/bloomee_tunes_linux_x64_v${version}.tar.gz";
    hash = "sha256-GeTDrMPAUfnkgRhWDrVhhFCVEKjTp1FbsUZ3rOdLVW0=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    gtk3
    wayland
    libxkbcommon
    libepoxy
    mpv
    libX11
    libXext
    libXcursor
    libXfixes
    libXrender
    libXinerama
    libXrandr
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "bloomeetunes";
      exec = "bloomeetunes";
      icon = "bloomeetunes";
      desktopName = "BloomeeTunes";
      genericName = "Music Player";
      categories = [ "AudioVideo" "Audio" "Player" ];
      keywords = [ "music" "player" "audio" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/${pname}
    cp -r * $out/opt/${pname}/

    ln -s $out/opt/${pname}/bloomee $out/bin/bloomeetunes

    install -Dm644 $out/opt/${pname}/data/flutter_assets/assets/icons/bloomee_new_logo_c.png $out/share/icons/hicolor/512x512/apps/bloomeetunes.png

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Bloomee is a cross-platform music app designed to bring you ad-free tunes from various sources.";
    homepage = "https://github.com/HemantKArya/BloomeeTunes";
    license = licenses.gpl2;
    maintainers = [ ];
    mainProgram = "bloomeetunes";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
