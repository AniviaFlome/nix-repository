{
  pkgs ? import <nixpkgs> { },
}:
{
  # MPV Scripts
  mpvScripts = pkgs.callPackage ./pkgs/mpvScripts { };

  # Applications
  applications = pkgs.callPackage ./pkgs/applications { };
}
