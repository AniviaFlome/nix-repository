{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  ydotool,
  wtype,
  xdotool,
  xprop,
  xwininfo,
  mkMultiArchUpdateScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.7.66";

  src =
    let
      arch =
        if stdenv.hostPlatform.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu";
      hashes = {
        x86_64-unknown-linux-gnu = "sha256-HK6YOawwIQ4w36Cej9V5iGHWEl9uIjVwE76G3qP60cw=";
        aarch64-unknown-linux-gnu = "sha256-NfuQBit8WJa5xvRlAuCMcjZj0qcVcBmdXLXM7jEYOEU=";
      };
    in
    fetchurl {
      url = "https://github.com/agent-sh/computer-use-linux/releases/download/v${finalAttrs.version}/computer-use-linux-${arch}";
      hash = hashes.${arch};
      name = "computer-use-linux";
    };

  cosmicSrc =
    let
      arch =
        if stdenv.hostPlatform.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu";
      hashes = {
        x86_64-unknown-linux-gnu = "sha256-45lf2mGhA0rpsFDh2qY0KnB1KBkjUjn5WkIGXSIL/ro=";
        aarch64-unknown-linux-gnu = "sha256-F7xtqxtOv2YCgJFypGuFnL39Cm4mOWPFyek2Ec5SyGU=";
      };
    in
    fetchurl {
      url = "https://github.com/agent-sh/computer-use-linux/releases/download/v${finalAttrs.version}/computer-use-linux-cosmic-${arch}";
      hash = hashes.${arch};
      name = "computer-use-linux-cosmic";
    };

  dontUnpack = true;

  skillSrc = fetchFromGitHub {
    owner = "agent-sh";
    repo = "computer-use-linux";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mwcG1HUc7oSARZMMfdsIJr8dlhs265u/ll+L7z4WzKo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/computer-use-linux
    install -Dm755 ${finalAttrs.cosmicSrc} $out/bin/computer-use-linux-cosmic

    wrapProgram $out/bin/computer-use-linux \
      --prefix PATH : "${
        lib.makeBinPath [
          ydotool
          wtype
          xdotool
          xprop
          xwininfo
        ]
      }"

    mkdir -p $out/share/skills/${finalAttrs.pname}
    cp -R "$skillSrc/skills/computer-use-linux" $out/share/skills/${finalAttrs.pname}/

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) cosmicSrc skillSrc;
    updateScript = mkMultiArchUpdateScript {
      file = "pkgs/computer-use-linux/default.nix";
      extraSystems = [ "aarch64-linux" ];
      extraArgs = [
        "--override-filename=pkgs/computer-use-linux/default.nix"
        "--subpackage=cosmicSrc"
        "--subpackage=skillSrc"
      ];
      extraSystemAttrs = [ "cosmicSrc" ];
    };
  };

  meta = with lib; {
    description = "Linux desktop control over MCP — accessibility tree, window targeting, screenshots, and input";
    homepage = "https://github.com/agent-sh/computer-use-linux";
    changelog = "https://github.com/agent-sh/computer-use-linux/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "computer-use-linux";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
