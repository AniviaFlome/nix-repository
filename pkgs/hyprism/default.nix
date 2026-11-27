{
  lib,
  buildFHSEnv,
  makeDesktopItem,
  hyprism-unwrapped,
  expat,
  fontconfig,
  freetype,
  glib,
  icu,
  libglvnd,
  libice,
  libsm,
  libx11,
  libxcomposite,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  libxtst,
  openssl,
  wayland,
  zlib,
}:

buildFHSEnv {
  pname = "hyprism";
  inherit (hyprism-unwrapped) version meta;

  targetPkgs = _: [
    hyprism-unwrapped
    expat
    fontconfig
    freetype
    glib
    icu
    libglvnd
    libice
    libsm
    libx11
    libxcomposite
    libxcursor
    libxext
    libxi
    libxkbcommon
    libxrandr
    libxtst
    openssl
    wayland
    zlib
  ];

  runScript = "${hyprism-unwrapped}/lib/hyprism/hyprism";

  extraInstallCommands =
    let
      desktopItems = [
        (makeDesktopItem {
          name = "hyprism";
          exec = "hyprism";
          icon = "hyprism";
          comment = "Hytale launcher with mod management";
          desktopName = "HyPrism";
          categories = [ "Game" ];
        })
      ];
    in
    ''
      mkdir -p $out/share
      ${lib.concatMapStringsSep "\n" (
        item: "cp -r --no-preserve=mode ${item}/share/* $out/share/"
      ) desktopItems}
      install -Dm644 ${hyprism-unwrapped}/share/icons/hicolor/scalable/apps/hyprism.svg \
        $out/share/icons/hicolor/scalable/apps/hyprism.svg
    '';

  passthru.unwrapped = hyprism-unwrapped;
}
