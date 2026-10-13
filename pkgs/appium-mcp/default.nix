{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  nix-update-script,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "appium-mcp";
  version = "1.97.1";

  src = fetchFromGitHub {
    owner = "appium";
    repo = "appium-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aNORt8F+EeDr9kXrro+Ns21UNH14vE0Zcl1NDP/MaV0=";
  };

  npmDepsHash = "sha256-E1moAVLedy/sZ5K0o0+FKT0Fe7hRitThW00NCdRn72E=";

  nodejs = nodejs_24;

  npmBuildScript = "build";

  passthru = {
    updateScript = nix-update-script { };
    tests.help = runCommand "appium-mcp-help" { } ''
      ${lib.getExe finalAttrs.finalPackage} --help >out.txt 2>&1
      grep -q "Usage: appium-mcp" out.txt
      touch $out
    '';
  };

  meta = with lib; {
    description = "Intelligent MCP server providing AI assistants with tools for Appium mobile automation";
    homepage = "https://github.com/appium/appium-mcp";
    changelog = "https://github.com/appium/appium-mcp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "appium-mcp";
    platforms = platforms.all;
  };
})
