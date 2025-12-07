{
  pkgs ? import <nixpkgs> { },
}:
{
  mpvScripts = pkgs.callPackage ./pkgs/mpvScripts { };
}
