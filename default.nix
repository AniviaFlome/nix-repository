{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  crystal-realms = pkgs.callPackage ./pkgs/crystal-realms { };
  waha-tui = pkgs.callPackage ./pkgs/waha-tui { };

  mpvScripts = {
    interSubs = pkgs.callPackage ./pkgs/mpvScripts/interSubs { };
    whisper-subs = pkgs.callPackage ./pkgs/mpvScripts/whisper-subs { };
  };
}
