# You can use this file as a nixpkgs overlay. This is useful in the case where you don't want to add the whole NUR namespace to your configuration.

_final: prev:
let
  nurAttrs = import ./default.nix { pkgs = prev; };
  # Automatically merge if attr exists in prev and both are attr sets
  shouldMerge = n: prev ? ${n} && builtins.isAttrs prev.${n} && builtins.isAttrs nurAttrs.${n};
in
builtins.mapAttrs (n: v: if shouldMerge n then prev.${n} // v else v) (
  builtins.removeAttrs nurAttrs [
    "lib"
    "overlays"
    "modules"
  ]
)
