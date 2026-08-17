{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  glib,
  gtk4,
  libadwaita,
  tesseract4,
  wl-clipboard,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waytator";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "faetalize";
    repo = "waytator";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-/Tq4fVrgss/v/+ugAueWCx1mbQlsyQ0LE4jRtIhT4qU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    glib
  ];

  buildInputs = [
    gtk4
    libadwaita
    tesseract4
    wl-clipboard
  ];

  mesonBuildType = "release";

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  meta = with lib; {
    description = "Screenshot annotator and lightweight image editor";
    homepage = "https://github.com/faetalize/waytator";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "waytator";
    platforms = platforms.linux;
  };
})
