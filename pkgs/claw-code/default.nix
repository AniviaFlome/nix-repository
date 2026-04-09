{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage rec {
  pname = "claw-code";
  version = "unstable-2026-04-09";

  src = fetchgit {
    url = "https://github.com/ultraworkers/claw-code.git";
    rev = "ff416ff3e775a9d6b526fc8c538076ad8a81c45a";
    hash = "sha256-1zcQz0mHlY7Mt0TSEQnfi+fATyJBlhaOk/i6gv+fiUI=";
  };

  sourceRoot = "${src.name}/rust";

  cargoHash = "sha256-P8QqUM1s/fNv7Fb4dmpJWDfTNumgUu1Cdiln8ybSDUU=";

  meta = with lib; {
    description = "A powerful agentic AI coding assistant";
    homepage = "https://github.com/ultraworkers/claw-code";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "claw";
  };
}
