{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  writeScript,
}:

buildDotnetModule rec {
  pname = "osu-beatmap-manager";
  version = "0-unstable-2026-02-25";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = pname;
    rev = "ab2b711d0de7ec8058aa40cd79a02774e654a8f9";
    hash = "sha256-WFQMTgObCr0kp0jcNdtJlVUeJzisT6jAaVKVMd8tbNA=";
  };

  projectFile = "src/OsuBeatmapManager/OsuBeatmapManager.csproj";
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
