{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "sldl-tui";
  version = "0-unstable-2026-05-19";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "sldl-tui";
    rev = "24085ba7fb06c56d0b99d993a138962b45ef25a0";
    hash = "sha256-rCm2Ftao1UrBYYZLAlT1PfNCrIvxJ9xygnhIm+AiEfc=";
  };

  cargoHash = "sha256-8uOWaA6RK0Nsb3qOx6KBhUnRHI2Z1oQy+AIzkWDAVz0=";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Simple TUI wrapper for sldl";
    homepage = "https://github.com/AniviaFlome/sldl-tui";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "sldl-tui";
    platforms = lib.platforms.linux;
  };
}
