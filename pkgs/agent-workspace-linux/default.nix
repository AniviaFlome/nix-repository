{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libxkbcommon,
  xorg,
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
  version = "0.3.2";

  src =
    let
      arch =
        if stdenv.hostPlatform.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu";
      hashes = {
        x86_64-unknown-linux-gnu = "sha256-EwQ094E3BGLDD8eTcQUoy9cjWNLpuZdtVmBqHY1kn10=";
        aarch64-unknown-linux-gnu = "sha256-zgFrJSUTuWdCTcH1QUW00PgwbNAHOySpk6Y767ubRFg=";
      };
    in
    fetchurl {
      url = "https://github.com/agent-sh/agent-workspace-linux/releases/download/v${finalAttrs.version}/agent-workspace-linux-${arch}";
      hash = hashes.${arch};
    };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    stdenv.cc.cc.lib
    xorg.libxcb
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
      }"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

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
