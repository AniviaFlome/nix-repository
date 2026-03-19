{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  writeScript,
}:

buildDotnetModule rec {
  pname = "osu-beatmap-manager";
  version = "0-unstable-2026-03-18";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = pname;
    rev = "c6981f927ba4ec22f0e7a0d0e8bf744f86980b9e";
    hash = "sha256-tl7mXRwYrqIOOsOF1dORiSti23jY51mzEdmgaBYV4Aw=";
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
