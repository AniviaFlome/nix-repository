{
  pkgs ? import <nixpkgs> { },
  upstreamMpvScripts ? pkgs.mpvScripts,
}:
{
  # MPV Scripts
  mpvScripts = pkgs.callPackage ./pkgs/mpvScripts { inherit upstreamMpvScripts; };

  # Applications
  applications = pkgs.callPackage ./pkgs/applications { };
}
