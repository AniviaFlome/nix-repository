{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "sldl-tui";
  version = "0-unstable-2026-05-17";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "sldl-tui";
    rev = "8b8ca52b8742833dfdd6661ad777ff527a56e314";
    hash = "sha256-jZu/pN/xoJrgfbuWqe0y6NbLbR4TVHef6kuEri6Tsgs=";
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
