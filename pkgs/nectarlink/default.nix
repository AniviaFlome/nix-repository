{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  ninja,
  qt6,
  libGL,
  vulkan-loader,
  libx11,
  libxkbcommon,
  libxtst,
  ffmpeg_8,
  openh264,
  lame,
  pulseaudio,
  pipewire,
  alsa-utils,
  wl-clipboard,
  xclip,
  xsel,
  xdg-utils,
  wmctrl,
  xdotool,
  xprop,
  testers,
  nix-update-script,
}:

let
  qtEnv = qt6.env "nectarlink-qt6-env" [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtwayland
    qt6.qtshadertools
    qt6.qttools
  ];

  dlopenLibs = [
    libGL
    vulkan-loader
    libx11
    libxkbcommon
    libxtst
    ffmpeg_8
    openh264
    lame
  ];

  runtimeBins = [
    ffmpeg_8
    pulseaudio
    pipewire
    alsa-utils
    wl-clipboard
    xclip
    xsel
    xdg-utils
    wmctrl
    xdotool
    xprop
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nectarlink";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "thtbee";
    repo = "nectarlink";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oWF3norm4REu361QIULK4gp5zxOfOeeBGNifZrRUWvQ=";
  };

  cargoHash = "sha256-l5QkWvxSSP5/gflHjUaNcNvIpNPFZltBbCGLb4Uj3BA=";

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;
  dontWrapQtApps = true;

  buildInputs = [
    qtEnv
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtwayland
    libGL
    vulkan-loader
    libx11
    libxkbcommon
    ffmpeg_8
  ];

  env = {
    LRELEASE = "${qtEnv}/bin/lrelease";
    QT_PLUGIN_PATH = "${qtEnv}/lib/qt-6/plugins";
    QML2_IMPORT_PATH = "${qtEnv}/lib/qt-6/qml";
  };

  preBuild = ''
    mkdir -p "$TMPDIR/qt-wrap"
    cat > "$TMPDIR/qt-wrap/qt.conf" <<EOF
    [Paths]
    Prefix = ${qtEnv}
    Headers = include
    Libraries = lib
    Plugins = lib/qt-6/plugins
    QmlImports = lib/qt-6/qml
    EOF
    ln -s "${qtEnv}/bin/qmake" "$TMPDIR/qt-wrap/qmake"
    export QMAKE="$TMPDIR/qt-wrap/qmake"
    export PATH="$TMPDIR/qt-wrap:$PATH"
  '';

  cargoBuildFlags = [
    "-p"
    "nectarlink-desktop"
    "-p"
    "nectarlink-cli"
  ];

  # Upstream tests exercise live sockets / platform services.
  doCheck = false;

  postInstall = ''
    # Translations (i18n.rs checks ../share/nectarlink relative to the binary)
    mkdir -p $out/share/nectarlink
    for qm in target/*/*/nectarlink_*.qm target/*/nectarlink_*.qm; do
      if [ -f "$qm" ]; then
        cp -n "$qm" $out/share/nectarlink/ || true
      fi
    done

    # Desktop integration & icons
    install -Dm644 desktop/packaging/linux/nectarlink.desktop \
      $out/share/applications/nectarlink.desktop
    install -Dm644 desktop/packaging/linux/org.nectarlink.desktop.metainfo.xml \
      $out/share/metainfo/org.nectarlink.desktop.metainfo.xml
    install -Dm644 assets/brand/icon.svg \
      $out/share/icons/hicolor/scalable/apps/nectarlink.svg
    install -Dm644 assets/brand/icon.svg \
      $out/share/pixmaps/nectarlink.svg
    install -Dm644 assets/brand/icon-512.png \
      $out/share/icons/hicolor/512x512/apps/nectarlink.png
    install -Dm644 assets/brand/icon-512.png \
      $out/share/pixmaps/nectarlink.png
  '';

  # Add dlopen()ed libraries to RUNPATH after fixupPhase's --shrink-rpath,
  # then wrap only the GUI binary with Qt paths and Linux helper tools.
  postFixup = ''
    patchelf --add-rpath "${lib.makeLibraryPath dlopenLibs}" \
      $out/bin/nectarlink-desktop

    wrapQtApp $out/bin/nectarlink-desktop \
      --suffix PATH : "${lib.makeBinPath runtimeBins}"
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--use-github-releases" ];
    };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "nectarlink --version";
    };
  };

  meta = {
    description = "Your Android phone and your PC, working as one (local-first, end-to-end encrypted)";
    homepage = "https://github.com/thtbee/nectarlink";
    changelog = "https://github.com/thtbee/nectarlink/releases/tag/v${finalAttrs.version}";
    license = [
      lib.licenses.gpl3Plus
      lib.licenses.mpl20
    ];
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "nectarlink-desktop";
  };
})
