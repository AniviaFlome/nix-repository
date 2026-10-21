# Shared predicate: does this package have a free license?
# Missing `meta`/`meta.license` falls back to "free", matching the old
# `p.meta.license or []` behavior in ci.nix (test derivations carry a
# `meta` without `license`). `tryEval` additionally guards licenses
# whose evaluation throws (e.g. unfree packages in pure evaluation),
# which report `false` instead of failing evaluation.
# NOTE: `tryEval` does not catch missing attributes on this Nix
# version, so the `or null` fallback below is load-bearing — do not
# "simplify" it back to a bare `pkg.meta.license`.
{ pkg }:
let
  result = builtins.tryEval ((pkg.meta or { }).license or null);
in
if result.success then
  let
    license = result.value;
  in
  if license == null then
    true
  else
    let
      licenses = if builtins.isList license then license else [ license ];
    in
    builtins.all (l: l.free or true) licenses
else
  false
