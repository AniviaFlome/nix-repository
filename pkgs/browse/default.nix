{
  lib,
  buildNpmPackage,
  fetchzip,
  nodejs_24,
  writeShellApplication,
  nix-update,
  curl,
  jq,
  git,
  gnutar,
  gzip,
  coreutils,
  testers,
}:

buildNpmPackage (finalAttrs: {
  pname = "browse";
  version = "0.0.15";

  src = fetchzip {
    url = "https://registry.npmjs.org/@opencode/browse/-/browse-${finalAttrs.version}.tgz";
    hash = "sha256-PQ5ZOVMCIXfHRdL0X8MhXxPlFJnepzFU99nWov+AA8g=";
  };

  npmDepsHash = "sha256-l0j9TzFaMVjDCtlVNVqzoQ3j2sZeYPdH8Z7iGwn3aSU=";

  nodejs = nodejs_24;

  postPatch = ''
    ${lib.getExe' nodejs_24 "node"} --eval '
      const pkg = require("./package.json");
      delete pkg.devDependencies;
      require("fs").writeFileSync("package.json", JSON.stringify(pkg, null, 2));
    '

    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  npmFlags = [ "--ignore-scripts" ];

  postInstall = ''
    mkdir -p $out/share/skills
    cp -R skills/browse $out/share/skills/
  '';

  passthru = {
    updateScript =
      let
        updater = writeShellApplication {
          name = "browse-update";
          runtimeInputs = [
            nix-update
            nodejs_24
            curl
            jq
            git
            gnutar
            gzip
            coreutils
          ];
          text = builtins.readFile ./update.sh;
        };
      in
      [ "${lib.getExe updater}" ];
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
    platforms = platforms.all;
  };
})
