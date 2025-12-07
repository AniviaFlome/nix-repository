{ pkgs ? import <nixpkgs> { } }:

rec {
  mpvScripts = pkgs.callPackage ./pkgs/mpvScripts { };
}
