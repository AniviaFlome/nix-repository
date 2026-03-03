{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  buildFHSEnv,
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
  makeDesktopItem,
  icu,
  openssl,
}:

let
  hyprism-unwrapped = stdenv.mkDerivation (finalAttrs: {
    pname = "hyprism-unwrapped";
    version = "3.0.1";

    src = fetchurl {
      url = "https://github.com/hyprismteam/HyPrism/releases/download/v${finalAttrs.version}/HyPrism-linux-x64-${finalAttrs.version}.tar.xz";
      hash = "sha256-uelinfGoJrvEvKKMP+jgZRU3sQln0Aup9oUqlLVVS2g=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    preferLocalBuild = true;

    dontStrip = true;

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
  });
in
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
      ${lib.concatMapStringsSep "\n" (item: "cp -r --no-preserve=mode ${item}/share/* $out/share/") desktopItems}
      install -Dm644 ${hyprism-unwrapped}/lib/hyprism/resources/bin/wwwroot/icon.png $out/share/icons/hicolor/800x800/apps/hyprism.png
    '';

  passthru.updateScript = nix-update-script { };
}
