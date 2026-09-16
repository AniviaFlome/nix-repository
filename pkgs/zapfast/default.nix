{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  libglvnd,
  wayland,
  libxkbcommon,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zapfast";
  version = "0.13.1";

  src =
    let
      arch =
        if stdenv.hostPlatform.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu";
      hashes = {
        x86_64-unknown-linux-gnu = "sha256-vbCd1ThOOCrV66L6w5FhyMz58QW56u6UUs2kFEHTm58=";
        aarch64-unknown-linux-gnu = "sha256-JoOYcmi/Xnv4BfBDHaqIV2qM+IRQjA6YNcxgTycUijQ=";
      };
    in
    fetchurl {
      url = "https://github.com/crmne/zapfast/releases/download/v${finalAttrs.version}/zapfast-v${finalAttrs.version}-${arch}.tar.gz";
      hash = hashes.${arch};
    };

  # The tarball extracts to zapfast-v<version>-<target>/.
  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # DT_NEEDED is only libasound + libstdc++; the Wayland/X11/EGL
  # libraries are dlopen()ed at runtime (see upstream
  # packaging/check-runtime-libs.c) so they are wrapped into
  # LD_LIBRARY_PATH below.
  buildInputs = [
    alsa-lib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    dir="zapfast-v${finalAttrs.version}-"*
    install -Dm755 $dir/zapfast $out/bin/zapfast
    install -Dm644 $dir/packaging/applications/zapfast.desktop $out/share/applications/zapfast.desktop
    install -Dm644 $dir/packaging/icons/zapfast.svg $out/share/icons/hicolor/scalable/apps/zapfast.svg

    wrapProgram $out/bin/zapfast \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          alsa-lib
          libglvnd
          wayland
          libxkbcommon
          libX11
          libXcursor
          libXi
          libXrandr
        ]
      }"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A native WhatsApp client built with Rust and egui";
    homepage = "https://github.com/crmne/zapfast";
    changelog = "https://github.com/crmne/zapfast/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "zapfast";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
