{
  pkgs ? import <nixpkgs> { },
}:

let
  lib = import ./lib { inherit pkgs; };
in
{
  inherit lib;
  modules = import ./modules;
  overlays = import ./overlays;

  dwproton = pkgs.callPackage ./pkgs/dwproton { inherit (lib) makeReleaseUpdater; };
  proton-cachyos = pkgs.callPackage ./pkgs/proton-cachyos { inherit (lib) makeReleaseUpdater; };
  waha-tui = pkgs.callPackage ./pkgs/waha-tui { };
  torrra = pkgs.callPackage ./pkgs/torrra { };
  turkanime-cli = pkgs.callPackage ./pkgs/turkanime-cli { };
  anitr-cli = pkgs.callPackage ./pkgs/anitr-cli { };
  turkanime-gui = pkgs.callPackage ./pkgs/turkanime-gui { };
  nativecookie = pkgs.callPackage ./pkgs/nativecookie { inherit (lib) makeReleaseUpdater; };
  osu-beatmap-manager = pkgs.callPackage ./pkgs/osu-beatmap-manager { };
  boson = pkgs.callPackage ./pkgs/boson { inherit (lib) makeReleaseUpdater; };
  cake-wallet-bin = pkgs.callPackage ./pkgs/cake-wallet-bin { };
  gdk-proton = pkgs.callPackage ./pkgs/gdk-proton { inherit (lib) makeReleaseUpdater; };
  getcomics-downloader = pkgs.callPackage ./pkgs/getcomics-downloader { };
  hyprism = pkgs.callPackage ./pkgs/hyprism { inherit (lib) makeReleaseUpdater; };

  artcnn = pkgs.callPackage ./pkgs/artcnn { };
  anime4k = pkgs.callPackage ./pkgs/anime4k { };
  fallin-soft = pkgs.callPackage ./pkgs/fallin-soft { };
  fallin-strong = pkgs.callPackage ./pkgs/fallin-strong { };

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
