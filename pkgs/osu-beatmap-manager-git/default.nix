{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  writeScript,
}:

buildDotnetModule rec {
  pname = "osu-beatmap-manager-git";
  version = "0-unstable-2026-03-18";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "osu-beatmap-manager";
    rev = "c6981f927ba4ec22f0e7a0d0e8bf744f86980b9e";
    hash = "sha256-tl7mXRwYrqIOOsOF1dORiSti23jY51mzEdmgaBYV4Aw=";
  };

  projectFile = "src/obm/obm.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  passthru.updateScript = writeScript "update-osu-beatmap-manager-git" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix-update

    set -euo pipefail

    nix-update osu-beatmap-manager-git --version branch
    $(nix-build -A osu-beatmap-manager-git.fetch-deps --no-out-link) ./pkgs/osu-beatmap-manager-git/deps.json
  '';

  meta = with lib; {
    description = "osu! Beatmap Manager";
    homepage = "https://github.com/AniviaFlome/osu-beatmap-manager";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "obm";
  };
}
