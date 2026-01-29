{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  dwproton = pkgs.callPackage ./pkgs/dwproton { };
  proton-cachyos = pkgs.callPackage ./pkgs/proton-cachyos { };
  waha-tui = pkgs.callPackage ./pkgs/waha-tui { };
  torrra = pkgs.callPackage ./pkgs/torrra { };
  turkanime-cli = pkgs.callPackage ./pkgs/turkanime-cli { };
  crystal-realms = pkgs.callPackage ./pkgs/crystal-realms { };
  anitr-cli = pkgs.callPackage ./pkgs/anitr-cli { };
  mpvScripts = {
    interSubs = pkgs.callPackage ./pkgs/mpvScripts/interSubs {
      inherit (pkgs.mpvScripts) buildLua;
    };
    subtitle-sync = pkgs.callPackage ./pkgs/mpvScripts/subtitle-sync {
      inherit (pkgs.mpvScripts) buildLua;
    };
    whisper-subs = pkgs.callPackage ./pkgs/mpvScripts/whisper-subs {
      inherit (pkgs.mpvScripts) buildLua;
    };
  };
}
