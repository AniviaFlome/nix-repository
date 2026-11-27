{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  libxkbcommon,
  wayland,
  libglvnd,
  vulkan-loader,
  libxcb,
  xvfb,
  xorg-server,
  xauth,
  xdpyinfo,
  xprop,
  xwininfo,
  openbox,
  xdotool,
  ffmpeg,
  imagemagick,
  xclip,
  bubblewrap,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agent-workspace-linux";
  version = "0.6.4";

  src =
    let
      arch =
        if stdenv.hostPlatform.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu";
      hashes = {
        x86_64-unknown-linux-gnu = "sha256-2RklPmNUC1fG59VmzXRoBUOYH995BS8Ak2fsPiZ9uBs=";
        aarch64-unknown-linux-gnu = "sha256-j0npXqdW4WTvaCupv1MqEm0iCIFhfzFm5nfpydBIKe0=";
      };
    in
    fetchurl {
      url = "https://github.com/agent-sh/agent-workspace-linux/releases/download/v${finalAttrs.version}/agent-workspace-linux-${arch}";
      hash = hashes.${arch};
    };

  dontUnpack = true;

  skillSrc = fetchFromGitHub {
    owner = "agent-sh";
    repo = "agent-workspace-linux";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pJdjk9YzXPMG4JLqHUMc/0Qg+eN97+6GMkuHXz26H8g=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    stdenv.cc.cc.lib
    libxcb
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/agent-workspace-linux

    wrapProgram $out/bin/agent-workspace-linux \
      --prefix PATH : "${
        lib.makeBinPath [
          xvfb
          xorg-server
          xauth
          xdpyinfo
          xprop
          xwininfo
          openbox
          xdotool
          ffmpeg
          imagemagick
          xclip
          bubblewrap
        ]
      }" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
          libglvnd
          vulkan-loader
        ]
      }"

    mkdir -p $out/share/skills/${finalAttrs.pname}
    cp -R "$skillSrc/skills/agent-workspace-linux" $out/share/skills/${finalAttrs.pname}/

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) skillSrc;
    updateScript = nix-update-script {
      extraArgs = [ "--subpackage=skillSrc" ];
    };
  };

  meta = with lib; {
    description = "Isolated Linux desktop workspaces for AI agents";
    homepage = "https://github.com/agent-sh/agent-workspace-linux";
    changelog = "https://github.com/agent-sh/agent-workspace-linux/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "agent-workspace-linux";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
