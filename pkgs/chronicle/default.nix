{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  gtk3,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  at-spi2-atk,
  libxkbcommon,
  libdrm,
  mesa,
  alsa-lib,
  nss,
  nspr,
  expat,
  cups,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chronicle";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/AniviaFlome/chronicle/releases/download/v${finalAttrs.version}/chronicle-linux-v${finalAttrs.version}.tar.gz";
    hash = "sha256-UREF5pJ2DD/4qo0e+DIj118rYp8CRYrjHnTeIWjgI8Y=";
  };

  icon = fetchurl {
    url = "https://raw.githubusercontent.com/AniviaFlome/chronicle/v${finalAttrs.version}/assets/icon/icon_foreground.png";
    hash = "sha256-82Yb9wEH8nQHGG0Fzr+PW3oTkyKZroB/hLcK6OiFBrM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    gtk3
    glib
    cairo
    pango
    gdk-pixbuf
    at-spi2-atk
    libxkbcommon
    libdrm
    mesa
    alsa-lib
    nss
    nspr
    expat
    cups
  ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  # libdartjni.so links libjvm.so, but the JVM is dlopen()ed at runtime
  # (Flutter/Dart JNI) and isn't needed to launch the app.
  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  desktopItems = [
    (makeDesktopItem {
      name = "chronicle";
      exec = "chronicle";
      icon = "chronicle";
      desktopName = "Chronicle";
      comment = "Cross-platform student planner";
      categories = [
        "Office"
        "Calendar"
        "Education"
      ];
      keywords = [
        "planner"
        "student"
        "schedule"
        "tasks"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/chronicle
    tar -xzf $src -C $out/opt/chronicle/

    makeWrapper $out/opt/chronicle/chronicle $out/bin/chronicle \
      --prefix LD_LIBRARY_PATH : "$out/opt/chronicle/lib"

    install -Dm644 ${finalAttrs.icon} $out/share/icons/hicolor/512x512/apps/chronicle.png

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Cross-platform student planner with class schedules, absences, tasks and exams";
    homepage = "https://github.com/AniviaFlome/chronicle";
    changelog = "https://github.com/AniviaFlome/chronicle/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "chronicle";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
