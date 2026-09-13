{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  ydotool,
  wtype,
  xdotool,
  xprop,
  xwininfo,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "computer-use-linux";
  version = "0.5.0";

  srcs =
    let
      arch =
        if stdenv.hostPlatform.isAarch64 then "aarch64-unknown-linux-gnu" else "x86_64-unknown-linux-gnu";
      hashes = {
        main = {
          x86_64-unknown-linux-gnu = "sha256-0h55gzb1xrae98hTKIZjmVD+JIVeLbsgXMPzRSiUAg4=";
          aarch64-unknown-linux-gnu = "sha256-UScY62T5HNjvyWEHJ/ZfQOyTIYv+dRprtg/jYmaOIqY=";
        };
        cosmic = {
          x86_64-unknown-linux-gnu = "sha256-wet2Dul9UNwVfWcRlWzYT5dwHJmIVbI8HvG9d2GaFFg=";
          aarch64-unknown-linux-gnu = "sha256-IlALWHrGUKw8yMTd2MdcD9ov0B9Or/0cpIKA3btiCvo=";
        };
      };
    in
    [
      (fetchurl {
        url = "https://github.com/agent-sh/computer-use-linux/releases/download/v${finalAttrs.version}/computer-use-linux-${arch}";
        hash = hashes.main.${arch};
        name = "computer-use-linux";
      })
      (fetchurl {
        url = "https://github.com/agent-sh/computer-use-linux/releases/download/v${finalAttrs.version}/computer-use-linux-cosmic-${arch}";
        hash = hashes.cosmic.${arch};
        name = "computer-use-linux-cosmic";
      })
    ];

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${builtins.elemAt finalAttrs.srcs 0} $out/bin/computer-use-linux
    install -Dm755 ${builtins.elemAt finalAttrs.srcs 1} $out/bin/computer-use-linux-cosmic

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

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

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
