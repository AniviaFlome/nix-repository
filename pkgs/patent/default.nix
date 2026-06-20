{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  openssl,
  nix-update-script,
}:

let
  hashes = {
    x86_64-linux = "sha256-nGJtNrVx4NqCRIyRtnbS+F7lMWMeB6emHeFtcfJyX5o=";
    aarch64-linux = "sha256-IAVlLPxYFM0RAmEo08gsg1zYHYM6A/7H8O1CB4PNTcM=";
  };

  arch =
    {
      x86_64-linux = "x86_64";
      aarch64-linux = "aarch64";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "patent";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/r14dd/patent/releases/download/v${finalAttrs.version}/patent-${arch}-unknown-linux-gnu.tar.xz";
    hash =
      hashes.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    openssl
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    install -Dm755 patent-*/patent $out/bin/patent
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Prior-art search for your code ideas";
    homepage = "https://github.com/r14dd/patent";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "patent";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
