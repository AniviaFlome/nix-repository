{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  nix-update-script,
  runCommand,
}:

buildNpmPackage (finalAttrs: {
  pname = "mobile-mcp";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "mobile-next";
    repo = "mobile-mcp";
    rev = "${finalAttrs.version}";
    hash = "sha256-nSA/l62dUXlPDq6VRBxWtTe4BXsAz519iGSzHM3VQuY=";
  };

  npmDepsHash = "sha256-+KntFutFtU95hWz0IJ+skDFqt7LbGbVI9bQ2xhzzbKk=";

  nodejs = nodejs_24;

  npmBuildScript = "build";

  passthru = {
    updateScript = nix-update-script { };
    # Upstream --version prints stale 0.0.1, so assert --help output instead.
    tests.help = runCommand "mobile-mcp-help" { } ''
      ${lib.getExe finalAttrs.finalPackage} --help >out.txt 2>&1
      grep -q -- "--listen" out.txt
      touch $out
    '';
  };

  meta = with lib; {
    description = "MCP server for mobile automation and scraping (iOS, Android, emulators, simulators and real devices)";
    homepage = "https://github.com/mobile-next/mobile-mcp";
    changelog = "https://github.com/mobile-next/mobile-mcp/releases/tag/${finalAttrs.version}";
    license = licenses.asl20;
    maintainers = [ ];
    mainProgram = "mcp-server-mobile";
    platforms = platforms.all;
  };
})
