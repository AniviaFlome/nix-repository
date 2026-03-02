{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeReleaseUpdater,
  gtk3,
  glib,
  nss,
  nspr,
  alsa-lib,
  cups,
  libdrm,
  expat,
  libxkbcommon,
  mesa,
  pango,
  cairo,
  at-spi2-atk,
  gdk-pixbuf,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hyprism";
  version = "3.0.1";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${finalAttrs.version}/HyPrism-linux-x64-${finalAttrs.version}.tar.xz";
    hash = "sha256-rtXlv7BTsYt1iwKCPlM3iUfDY8C5JH7CV92Vy20Gi3s=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  preferLocalBuild = true;

  buildInputs = [
    gtk3
    glib
    nss
    nspr
    alsa-lib
    cups
    libdrm
    expat
    libxkbcommon
    mesa
    pango
    cairo
    at-spi2-atk
    gdk-pixbuf
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/hyprism

    cp -r * $out/lib/hyprism/

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "hyprism";
      desktopName = "HyPrism";
      exec = "hyprism";
      icon = "hyprism";
      comment = "Hytale launcher with mod management";
      categories = [
        "Game"
      ];
    })
  ];

  passthru.updateScript = makeReleaseUpdater {
    name = "hyprism";
    repo = "https://api.github.com/repos/hyprismteam/HyPrism/releases";
  };

  meta = {
    description = "Hytale launcher with mod management";
    homepage = "https://github.com/HyPrismTeam/HyPrism";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "hyprism";
  };
})
