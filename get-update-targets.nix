{ system ? builtins.currentSystem }:
let
  flake = builtins.getFlake (toString ./.);
  packages = flake.packages.${system};

  find = prefix: attrs:
    if builtins.isAttrs attrs then
      if (attrs ? type && attrs.type == "derivation") then
        if (attrs.passthru ? updateScript) then
          [ prefix ]
        else
          []
      else
        builtins.concatLists (map (name:
          find (if prefix == "" then name else "${prefix}.${name}") attrs.${name}
        ) (builtins.attrNames attrs))
    else
      [];
in
find "" packages
