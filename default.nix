{
  pkgs ? import <nixpkgs> { },
  upstreamMpvScripts ? pkgs.mpvScripts,
}:
{
  mpvScripts = pkgs.callPackage ./pkgs/mpvScripts { inherit upstreamMpvScripts; };
}
