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
  version = "0.1.5";

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
        linux-x64 = "sha256-i6c/FjIqQlRMrTqXSQv9FJV7l7EItY9DkT5soIijzdc=";
        linux-arm64 = "sha256-C1UOi2YjmUqUe8mYcEtLxeeW4wcyPeX5R81KvXx9fas=";
        darwin-x64 = "sha256-/PiaQKnbNIYY7cqRT+hLooS0jH7PWCmeF0gFYHJjtYk=";
        darwin-arm64 = "sha256-1jsw2bidBQcKMxDS2AQ14Gq5zDUha4AazGj5aeFCAr8=";
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
