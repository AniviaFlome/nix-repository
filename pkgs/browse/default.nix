{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "browse";
  version = "0.1.0";

  # Upstream ships the Rust binary as per-platform npm packages
  # (@opencode/browse-<target> holding bin/browse); the main
  # @opencode/browse tarball is only a Node launcher, so fetch the
  # platform tarball directly instead.
  src =
    let
      target =
        if stdenv.hostPlatform.isDarwin then
          if stdenv.hostPlatform.isAarch64 then "darwin-arm64" else "darwin-x64"
        else if stdenv.hostPlatform.isAarch64 then
          "linux-arm64"
        else
          "linux-x64";
      hashes = {
        linux-x64 = "sha256-bjzhOxwLmPnLLPOscNvkBXQ02sRzgxM9vcTn8fCDKHk=";
        linux-arm64 = "sha256-J0BaPHpgftH0uPOoOQ4LsPcqI3mGZNqfV+jE5xf0ltM=";
        darwin-x64 = "sha256-2uMY6LVLuzNKSyIte4WUgEPb5bq1X0ScQ13/tolRPJ8=";
        darwin-arm64 = "sha256-bzmc+q/RHWHnImBAf/8AcUkkm4f1zxKH7B3fMDUSD54=";
      };
    in
    fetchurl {
      url = "https://registry.npmjs.org/@opencode/browse-${target}/-/browse-${target}-${finalAttrs.version}.tgz";
      hash = hashes.${target};
    };

  sourceRoot = "package";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/browse $out/bin/browse

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };
  };

  meta = with lib; {
    description = "Let your AI agents use your real browser: an MCP server and a Chromium extension";
    homepage = "https://github.com/anomalyco/browse";
    changelog = "https://github.com/anomalyco/browse/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "browse";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
