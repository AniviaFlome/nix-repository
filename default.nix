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
  anitr-cli = pkgs.callPackage ./pkgs/anitr-cli { };
  turkanime-gui = pkgs.callPackage ./pkgs/turkanime-gui { };
  nativecookie = pkgs.callPackage ./pkgs/nativecookie { };
  boson = pkgs.callPackage ./pkgs/boson { };
  cake-wallet-bin = pkgs.callPackage ./pkgs/cake-wallet-bin { };
  gdk-proton = pkgs.callPackage ./pkgs/gdk-proton { };
  getcomics-downloader = pkgs.callPackage ./pkgs/getcomics-downloader { };
  mpvScripts =
    let
      callMpvScript =
        path:
        pkgs.callPackage path {
          inherit (pkgs.mpvScripts) buildLua;
        };
    in
    {
      interSubs = callMpvScript ./pkgs/mpvScripts/interSubs;
      subtitle-sync = callMpvScript ./pkgs/mpvScripts/subtitle-sync;
      whisper-subs = callMpvScript ./pkgs/mpvScripts/whisper-subs;
      cheatsheet = callMpvScript ./pkgs/mpvScripts/cheatsheet;
    };
}
