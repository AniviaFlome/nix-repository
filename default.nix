{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  inter-subs = pkgs.callPackage ./pkgs/mpvScripts/interSubs { };
  whisper-subs = pkgs.callPackage ./pkgs/mpvScripts/whisper-subs { };
  meetily = pkgs.callPackage ./pkgs/applications/meetily { };
}
