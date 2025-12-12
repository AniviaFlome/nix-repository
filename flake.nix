{
  description = "Nix Repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      flake.overlays.default =
        final: prev:
        let
          nur = import ./. { pkgs = prev; };
        in
        {
          mpvScripts = prev.mpvScripts // nur.mpvScripts;
        }
        // nur.applications;

      perSystem =
        { pkgs, ... }:
        let
          nur = import ./default.nix { inherit pkgs; };
        in
        {
          legacyPackages = nur;

          treefmt.config = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              shfmt.enable = true;
            };
          };
        };
    };
}

