# Minimal `maintainers/scripts/update.nix` shim (nixpkgs layout contract).
#
# `nix-update --use-update-script` in file mode (no `--flake`) unconditionally
# runs `nix-shell <repo>/maintainers/scripts/update.nix --argstr package
# <dotted-attrpath> --argstr skip-prompt true`. This file implements exactly
# that contract for this repository: it resolves the package from our own
# `default.nix` and executes its `passthru.updateScript` with the same
# `UPDATE_NIX_*` environment `nix-update` sets in flake mode.
# `skip-prompt` is accepted and ignored: our update scripts never prompt.
{ package, ... }:
let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  nurPkgs = import ../../default.nix { inherit pkgs; };
  pkg =
    lib.attrByPath (lib.splitString "." package)
      (throw "Package '${package}' does not exist in this repository.")
      nurPkgs;
  script = lib.escapeShellArgs (
    lib.toList (pkg.passthru.updateScript.command or pkg.passthru.updateScript)
  );
in
pkgs.stdenv.mkDerivation {
  name = "nur-update-script";
  buildCommand = ''
    echo "This file is only meant to be run via 'nix-shell maintainers/scripts/update.nix --argstr package <name>' by nix-update in file mode." >&2
    exit 1
  '';
  shellHook = ''
    unset shellHook # do not contaminate nested shells
    export UPDATE_NIX_NAME="${pkg.name}"
    export UPDATE_NIX_PNAME="${pkg.pname or pkg.name}"
    export UPDATE_NIX_OLD_VERSION="${pkg.version}"
    export UPDATE_NIX_ATTR_PATH="${package}"
    exec ${script}
  '';
}
