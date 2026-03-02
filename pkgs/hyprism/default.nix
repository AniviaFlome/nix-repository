{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  nix-update-script,
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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hyprism";
  version = "3.0.1";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${finalAttrs.version}/HyPrism-linux-x64-${finalAttrs.version}.tar.xz";
    hash = "sha256-uelinfGoJrvEvKKMP+jgZRU3sQln0Aup9oUqlLVVS2g=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
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

  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/hyprism

    cp -r * $out/lib/hyprism/

    ln -s $out/lib/hyprism/HyPrism $out/bin/hyprism

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
    mainProgram = "hyprism";
  };
})
