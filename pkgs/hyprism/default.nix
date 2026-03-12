{
  lib,
  buildFHSEnv,
  makeDesktopItem,
  hyprism-unwrapped,
  icu,
  openssl,
  libGL,
}:

buildFHSEnv {
  pname = "hyprism";
  inherit (hyprism-unwrapped) version meta;

  targetPkgs = _: [
    hyprism-unwrapped
    icu
    openssl
    libGL
  ];

  runScript = "${hyprism-unwrapped}/lib/hyprism/HyPrism";

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
      install -Dm644 ${hyprism-unwrapped}/lib/hyprism/resources/app/dist/icon.png $out/share/icons/hicolor/512x512/apps/hyprism.png
    '';

  passthru.unwrapped = hyprism-unwrapped;
}
