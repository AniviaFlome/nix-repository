{
  description = "Nix Repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, treefmt-nix }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      packageNames = builtins.attrNames (builtins.readDir ./packages);
      mkMpvScripts = callPackage: nixpkgs.lib.genAttrs packageNames (name: 
        callPackage (./packages + "/${name}") { }
      );

      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });

      packages = eachSystem (pkgs: 
        let
          generalPkgs = loadPkgs ./pkgs/applicatons pkgs.callPackage;
          myMpvScripts = loadPkgs ./pkgs/mpv-scripts pkgs.callPackage;
        in
          generalPkgs // { 
            mpvScripts = myMpvScripts;
          }
      );

      overlays.default = final: prev: 
        let
          generalPkgs = loadPkgs ./packages final.callPackage;
          myMpvScripts = loadPkgs ./mpv-scripts final.callPackage;
        in
          generalPkgs // { 
            mpvScripts = myMpvScripts;
          };
    };
}