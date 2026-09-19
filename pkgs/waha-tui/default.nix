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
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "muhammedaksam";
    repo = "waha-tui";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6cR++LkPS77xSTZ+H+oI214pTuSS9s6FZuiq0EjVjc4=";
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
    outputHash = "sha256-7FdWBx8s1NVf1M7q9J/iyBmVFt9I15J+Ko+qSCsySB4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

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
