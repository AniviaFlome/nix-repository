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
  tesseract4,
  wayland,
  wayland-protocols,
  wl-clipboard,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waytator";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "faetalize";
    repo = "waytator";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-OnEUDSxKJCZsN0v2BV/QQ8ceI4BSaY9LH+QucziY1EA=";
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
    gtk4
    gtk4-layer-shell
    libadwaita
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
