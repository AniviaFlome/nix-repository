{
  pkgs,
}:

let
  inherit (pkgs) lib;
in
{
  collectTests =
    attrs:
    let
      isFree = pkg: import ./is-free.nix { inherit pkg; };
      testsFromPkg =
        name: pkg:
        let
          probe = builtins.tryEval (lib.isAttrs pkg && pkg ? passthru && pkg.passthru ? tests && isFree pkg);
        in
        if probe.success && probe.value then
          lib.mapAttrs' (testName: drv: lib.nameValuePair "${name}-${testName}" drv) (
            lib.filterAttrs (_: v: lib.isDerivation v) pkg.passthru.tests
          )
        else
          { };
    in
    lib.foldlAttrs (
      acc: name: pkg:
      acc // testsFromPkg name pkg
    ) { } attrs;
}
