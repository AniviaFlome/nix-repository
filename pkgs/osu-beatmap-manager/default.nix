{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  writeScript,
}:

buildDotnetModule rec {
  pname = "osu-beatmap-manager";
  version = "0-unstable-2026-02-26";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = pname;
    rev = "57f960243ac5bd1c2cbf0c9704d82b502f974f24";
    hash = "sha256-PDh50sf/r+vXYZRep5JEzO9sZZjEh5q/Fc+70LVGsDE=";
  };

  projectFile = "src/obm/obm.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  passthru.updateScript = writeScript "update-osu-beatmap-manager" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix-update

    set -euo pipefail

    nix-update osu-beatmap-manager --version branch
    $(nix-build -A osu-beatmap-manager.fetch-deps --no-out-link) ./pkgs/osu-beatmap-manager/deps.json
  '';

  meta = with lib; {
    description = "osu! Beatmap Manager";
    homepage = "https://github.com/AniviaFlome/osu-beatmap-manager";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "obm";
  };
}
