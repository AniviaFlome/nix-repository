{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  mpvScripts = {
    interSubs = pkgs.callPackage ./pkgs/mpvScripts/interSubs { };
    whisper-subs = pkgs.callPackage ./pkgs/mpvScripts/whisper-subs { };
  };
}
