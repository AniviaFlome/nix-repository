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
  libGL,
  pango,
  cairo,
  at-spi2-atk,
  gdk-pixbuf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hyprism-unwrapped";
  version = "3.0.2";

  src = fetchurl {
    url = "https://github.com/hyprismteam/HyPrism/releases/download/v${finalAttrs.version}/HyPrism-linux-x64-${finalAttrs.version}.tar.xz";
    hash = "sha256-GfvjL6Fqmta1DyJ1MjerxpM0z3IaMLQ8oFL7VBkXYPs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
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
    libGL
    pango
    cairo
    at-spi2-atk
    gdk-pixbuf
  ];

  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/hyprism

    cp -r * $out/lib/hyprism/

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
