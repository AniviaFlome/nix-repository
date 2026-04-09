{
  packages,
}:
let
  # Determine if updateScript is a custom script or nix-update style
  getScriptInfo =
    pkg:
    if pkg ? passthru && pkg.passthru ? updateScript then
      let
        script = pkg.passthru.updateScript;
      in
      if builtins.isList script then
        # nix-update style: list like ["/nix/store/.../nix-update", "--subpackage=bunDeps"]
        {
          useUpdateScript = false;
          extraArgs = builtins.filter (
            arg: builtins.isString arg && builtins.substring 0 1 arg == "-"
          ) script;
        }
      else
        # Custom script (writeScript, path, derivation) - use nix-update --use-update-script
        {
          useUpdateScript = true;
          extraArgs = [ ];
        }
    else
      # No updateScript — nix-update will auto-detect version and hash
      {
        useUpdateScript = false;
        extraArgs = [ ];
      };

  find =
    prefix: attrs:
    if builtins.isAttrs attrs then
      if (attrs ? type && attrs.type == "derivation") then
        let
          info = getScriptInfo attrs;
        in
        [
          {
            name = prefix;
            inherit (info) useUpdateScript extraArgs;
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
