{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  writeScript,
}:

buildDotnetModule rec {
  pname = "osu-beatmap-manager-git";
  version = "0-unstable-2026-04-18";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "osu-beatmap-manager";
    rev = "aaea48ecb3c6875e074389a8b0c059f6e9b7e0ae";
    hash = "sha256-AUftnZ0/p9INaiKAlO8QBLZVjuI+haBOEJCpqOap9Ko=";
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
