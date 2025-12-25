{
  system ? builtins.currentSystem,
}:
let
  flake = builtins.getFlake (toString ./..); # parent directory
  packages = flake.packages.${system};

  # Extract extra args from updateScript (it's a list like ["/nix/store/.../nix-update", "--subpackage=bunDeps"])
  getExtraArgs =
    pkg:
    if pkg ? passthru && pkg.passthru ? updateScript then
      let
        script = pkg.passthru.updateScript;
      in
      if builtins.isList script then
        # Filter out the nix-update binary path and keep only the args
        builtins.filter (arg: builtins.isString arg && builtins.substring 0 1 arg == "-") script
      else
        [ ]
    else
      [ ];

  find =
    prefix: attrs:
    if builtins.isAttrs attrs then
      if (attrs ? type && attrs.type == "derivation") then
        if (attrs.passthru ? updateScript) then
          [
            {
              name = prefix;
              extraArgs = getExtraArgs attrs;
            }
          ]
        else
          [ ]
      else
        builtins.concatLists (
          map (name: find (if prefix == "" then name else "${prefix}.${name}") attrs.${name}) (
            builtins.attrNames attrs
          )
        )
    else
      [ ];
in
find "" packages
