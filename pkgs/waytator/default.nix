{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  wayland-scanner,
  glib,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  ffmpeg,
  libdrm,
  libgbm,
  libglvnd,
  pipewire,
  rubberband,
  tesseract4,
  wayland,
  wayland-protocols,
  wl-clipboard,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waytator";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "faetalize";
    repo = "waytator";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-u4YP5zX1pMw5Efa6b/pmcLhXNB5UbCj1gNyCDialTTU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    wayland-scanner
    glib
  ];

  buildInputs = [
    ffmpeg
    gtk4
    gtk4-layer-shell
    libadwaita
    libdrm
    libgbm
    libglvnd
    pipewire
    rubberband
    tesseract4
    wayland
    wayland-protocols
    wl-clipboard
  ];

  mesonBuildType = "release";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Screenshot annotator and lightweight image editor";
    homepage = "https://github.com/faetalize/waytator";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "waytator";
    platforms = platforms.linux;
  };
})
