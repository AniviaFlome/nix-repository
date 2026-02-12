{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  cacert,
  makeWrapper,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "waha-tui";
  version = "1.5.14";

  src = fetchFromGitHub {
    owner = "muhammedaksam";
    repo = "waha-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MV9Bpj+bs1CIL8Evw/btDQuvvdrtHNQ3Kyi0m4Xp1HM=";
  };

  bunDeps = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-bun-deps";
    inherit (finalAttrs) version src;

    nativeBuildInputs = [
      bun
      cacert
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      bun install --frozen-lockfile --ignore-scripts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r node_modules $out

      runHook postInstall
    '';

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-kjrQOZ3/sJwu+RXBYCS9sWYBdRiYfsjluAvbleFVuJI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/waha-tui $out/bin

    cp -r src package.json $out/lib/waha-tui/
    cp -r ${finalAttrs.bunDeps} $out/lib/waha-tui/node_modules

    makeWrapper ${bun}/bin/bun $out/bin/waha-tui \
      --add-flags "run $out/lib/waha-tui/src/index.ts"

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) bunDeps;
    updateScript = nix-update-script { extraArgs = [ "--subpackage=bunDeps" ]; };
  };

  meta = with lib; {
    description = "A beautiful Terminal User Interface for WhatsApp using WAHA (WhatsApp HTTP API)";
    homepage = "https://github.com/muhammedaksam/waha-tui";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "waha-tui";
    platforms = platforms.all;
  };
})
