{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  waha-tui = pkgs.callPackage ./pkgs/waha-tui { };
  mpvScripts = {
    interSubs = pkgs.callPackage ./pkgs/mpvScripts/interSubs { inherit (pkgs.mpvScripts) buildLua; };
    subtitle-sync = pkgs.callPackage ./pkgs/mpvScripts/subtitle-sync {
      inherit (pkgs.mpvScripts) buildLua;
    };
    whisper-subs = pkgs.callPackage ./pkgs/mpvScripts/whisper-subs {
      inherit (pkgs.mpvScripts) buildLua;
    };
  };
}
