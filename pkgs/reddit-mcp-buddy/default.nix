{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_24,
  nix-update-script,
  testers,
}:

buildNpmPackage (finalAttrs: {
  pname = "reddit-mcp-buddy";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "karanb192";
    repo = "reddit-mcp-buddy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-H8CgbemU/YVE1Gbc/lECYVUBnsR6DvdXqR0sLopuwUg=";
  };

  npmDepsHash = "sha256-7SBMGKD6FYqrO4yUGyty14Up12oPa6AK7RJJcy+y8a0=";

  nodejs = nodejs_24;

  npmBuildScript = "build";

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };
  };

  meta = with lib; {
    description = "Clean, LLM-optimized Reddit MCP server. Browse posts, search content, analyze users";
    homepage = "https://github.com/karanb192/reddit-mcp-buddy";
    changelog = "https://github.com/karanb192/reddit-mcp-buddy/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "reddit-mcp-buddy";
    platforms = platforms.all;
  };
})
