{
  packages,
}:
let
  # Whether the package carries its own updater. The updateScript is the
  # single source of truth (nixpkgs model): the runner executes it via
  # `nix-update --use-update-script` and never reassembles its flags.
  hasUpdateScript = pkg: pkg ? passthru && pkg.passthru ? updateScript;

  # Whether a package has a free license (shared helper: unfree or
  # throw-on-access licenses report false instead of failing evaluation).
  isFree = pkg: import ./is-free.nix { inherit pkg; };

  find =
    prefix: attrs:
    if builtins.isAttrs attrs then
      if (attrs ? type && attrs.type == "derivation") then
        [
          {
            name = prefix;
            hasUpdateScript = hasUpdateScript attrs;
            unfree = !(isFree attrs);
            nested = builtins.match ".*\\..*" prefix != null;
            prReview = attrs.passthru.updatePr or false;
          }
        ]
      else
        builtins.concatLists (
          builtins.attrValues (
            builtins.mapAttrs (
              name: value: find (if prefix == "" then name else "${prefix}.${name}") value
            ) attrs
          )
        )
    else
      [ ];
in
find "" packages
