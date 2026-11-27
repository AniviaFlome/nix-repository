{
  packages,
}:
let
  # Whether the package carries its own updater. The updateScript is the
  # single source of truth (nixpkgs model): the runner executes it via
  # `nix-update --use-update-script` and never reassembles its flags.
  hasUpdateScript = pkg: pkg ? passthru && pkg.passthru ? updateScript;

  find =
    prefix: attrs:
    if builtins.isAttrs attrs then
      if (attrs ? type && attrs.type == "derivation") then
        if hasUpdateScript attrs then
          [
            {
              name = prefix;
              hasUpdateScript = true;
              prReview = attrs.passthru.updatePr or false;
              extraBuildAttrs = attrs.passthru.extraBuildAttrs or [ ];
            }
          ]
        else
          [ ]
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
