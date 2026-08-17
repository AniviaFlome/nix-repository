{
  pkgs ? import <nixpkgs> { },
}:

let
  nurLib = import ./default.nix { inherit pkgs; };

  updater = nurLib.makeReleaseUpdater {
    name = "test-pkg";
    repo = "https://api.example.com/test/releases";
    versionFilter = "sed 's/^v//'";
  };

  inherit (pkgs) lib runCommand;

  pureEvalTests = lib.debug.runTests {
    testMakeReleaseUpdaterDefaultPname = {
      expr =
        (nurLib.makeReleaseUpdater {
          name = "foo";
          repo = "x";
        }).name or null != null;
      expected = true;
    };
  };

  # Turn the pure-eval test result into a buildable derivation so it can
  # participate in `nix flake check` / `ci.nix`. An empty list means all
  # tests passed; a non-empty list makes the derivation fail to build.
  pureEvalCheck =
    runCommand "test-makeReleaseUpdater-pureEval"
      {
        meta.timeout = 30;
      }
      ''
        ${lib.optionalString (pureEvalTests != [ ]) "false"}
        touch $out
      '';

  scriptExists =
    runCommand "test-makeReleaseUpdater-exists"
      {
        nativeBuildInputs = [ ];
        meta.timeout = 30;
      }
      ''
        test -x ${updater}
        grep -q "api.example.com/test/releases" ${updater}
        grep -q "test-pkg" ${updater}
        touch $out
      '';

  collectTests =
    attrs:
    let
      isFree =
        pkg:
        let
          result = builtins.tryEval pkg.meta.license;
        in
        if result.success then
          let
            license = result.value;
            licenses = if lib.isList license then license else [ license ];
          in
          builtins.all (l: l.free or true) licenses
        else
          false;
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
in
{
  inherit
    pureEvalTests
    pureEvalCheck
    scriptExists
    collectTests
    ;
}
