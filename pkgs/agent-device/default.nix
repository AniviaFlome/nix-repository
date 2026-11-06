{
  lib,
  stdenv,
  fetchurl,
  nodejs_24,
  makeWrapper,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "agent-device";
  version = "0.21.36";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-device/-/agent-device-${finalAttrs.version}.tgz";
    hash = "sha256-Cq2Ia0fQal7KjlTTKpdmmF8jKD9JrcHFBFUJoZG8pco=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agent-device $out/bin
    cp -R -- . $out/lib/agent-device

    makeWrapper ${lib.getExe nodejs_24} $out/bin/agent-device \
      --add-flags "$out/lib/agent-device/bin/agent-device.mjs"

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };
  };

  meta = with lib; {
    description = "Open source device layer for AI coding agents: a CLI, MCP server, and typed Node.js API to control mobile, web, TV, and desktop apps on devices and simulators, locally or in the cloud.";
    homepage = "https://agent-device.dev";
    changelog = "https://github.com/callstack/agent-device/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "agent-device";
    platforms = platforms.all;
  };
})
