{
  description = "Nix Repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      treefmtEval = system: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix;
    in
    {
      formatter = forAllSystems (system: (treefmtEval system).config.build.wrapper);

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          nurAttrs = import ./default.nix { inherit pkgs; };
          inherit (import ./lib/tests.nix { inherit pkgs; }) collectTests scriptExists pureEvalCheck;
        in
        {
          formatting = (treefmtEval system).config.build.check self;
          lib-makeReleaseUpdater = scriptExists;
          lib-makeReleaseUpdater-pureEval = pureEvalCheck;
        }
        // collectTests (nurAttrs.mpvScripts or { })
        // collectTests (
          removeAttrs nurAttrs [
            "lib"
            "modules"
            "overlays"
            "mpvScripts"
          ]
        )
      );

      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );

      packages = forAllSystems (
        system:
        let
          lp = self.legacyPackages.${system};
          topLevel = nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) lp;
          nested = nixpkgs.lib.concatMapAttrs (
            outerName: outerVal:
            if builtins.isAttrs outerVal && !(nixpkgs.lib.isDerivation outerVal) then
              nixpkgs.lib.mapAttrs' (
                innerName: innerVal: nixpkgs.lib.nameValuePair "${outerName}-${innerName}" innerVal
              ) (nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) outerVal)
            else
              { }
          ) lp;
        in
        topLevel // nested
      );

      overlays.default = import ./overlay.nix;
    };
}
