{
  lib,
  writeShellScript,
  nix-update,
  coreutils,
  jq,
  gnused,
}:
{
  file,
  extraSystems,
  extraArgs ? [ ],
  extraSystemAttrs ? [ ],
}:
let
  attrList = [ "src" ] ++ extraSystemAttrs;
  nixUpdateArgs = lib.escapeShellArgs extraArgs;
  systemsStr = lib.escapeShellArgs extraSystems;
  attrsStr = lib.escapeShellArgs attrList;
in
writeShellScript "multi-arch-update-${baseNameOf (dirOf file)}" ''
  set -euo pipefail

  file=${lib.escapeShellArg file}
  attr="''${UPDATE_NIX_ATTR_PATH:?UPDATE_NIX_ATTR_PATH must be set}"

  before=$(${coreutils}/bin/sha256sum "$file")
  ${lib.getExe nix-update} "$attr" ${nixUpdateArgs}
  after=$(${coreutils}/bin/sha256sum "$file")

  if [ "$before" = "$after" ] && [ -z "''${FORCE_MULTI_ARCH_REFRESH:-}" ]; then
    exit 0
  fi

  for sys in ${systemsStr}; do
    for sub in ${attrsStr}; do
      info=$(
        nix eval --impure --json --expr "
          let
            pkgs = import <nixpkgs> { system = \"$sys\"; };
            nur = import ./default.nix { inherit pkgs; };
            drv = nur.\"$attr\".\"$sub\";
          in {
            url = drv.url or (builtins.head drv.urls);
            hash = drv.outputHash;
          }
        "
      )
      url=$(printf '%s' "$info" | ${lib.getExe jq} -r '.url')
      old_hash=$(printf '%s' "$info" | ${lib.getExe jq} -r '.hash')

      raw_hash=$(nix-prefetch-url --type sha256 "$url")
      new_hash=$(nix-hash --to-sri --type sha256 "$raw_hash")

      if [ "$new_hash" != "$old_hash" ]; then
        echo "Updated $attr.$sub ($sys): $old_hash -> $new_hash"
        ${lib.getExe gnused} -i "s|$old_hash|$new_hash|g" "$file"
      fi
    done
  done
''
