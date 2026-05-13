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

  dwproton-bin = pkgs.callPackage ./pkgs/dwproton-bin { inherit (lib) makeReleaseUpdater; };
  proton-cachyos-bin = pkgs.callPackage ./pkgs/proton-cachyos-bin {
    inherit (lib) makeReleaseUpdater;
  };
  waha-tui = pkgs.callPackage ./pkgs/waha-tui { };
  torrra-bin = pkgs.callPackage ./pkgs/torrra-bin { };
  turkanime-cli = pkgs.callPackage ./pkgs/turkanime-cli { };
  anitr-cli = pkgs.callPackage ./pkgs/anitr-cli { };
  turkanime-gui = pkgs.callPackage ./pkgs/turkanime-gui { };
  nativecookie-bin = pkgs.callPackage ./pkgs/nativecookie-bin { inherit (lib) makeReleaseUpdater; };
  osu-beatmap-manager-git = pkgs.callPackage ./pkgs/osu-beatmap-manager-git { };
  boson-bin = pkgs.callPackage ./pkgs/boson-bin { inherit (lib) makeReleaseUpdater; };
  cake-wallet-bin = pkgs.callPackage ./pkgs/cake-wallet-bin { };
  gdk-proton-bin = pkgs.callPackage ./pkgs/gdk-proton-bin { inherit (lib) makeReleaseUpdater; };
  getcomics-downloader = pkgs.callPackage ./pkgs/getcomics-downloader { };
  handy-bin = pkgs.callPackage ./pkgs/handy-bin { };
  hyprism-unwrapped = pkgs.callPackage ./pkgs/hyprism/unwrapped.nix { };
  hyprism = pkgs.callPackage ./pkgs/hyprism {
    hyprism-unwrapped = pkgs.callPackage ./pkgs/hyprism/unwrapped.nix { };
  };
  artcnn = pkgs.callPackage ./pkgs/artcnn { };
  fallin = pkgs.callPackage ./pkgs/fallin { };
  adore = pkgs.callPackage ./pkgs/adore { };
  crankshaft-bin = pkgs.callPackage ./pkgs/crankshaft-bin { };
  motrix-next-bin = pkgs.callPackage ./pkgs/motrix-next-bin { };
  bloomeetunes-bin = pkgs.callPackage ./pkgs/bloomeetunes-bin { };
  kopuz-bin = pkgs.callPackage ./pkgs/kopuz-bin { };

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
      file-browser = callMpvScript ./pkgs/mpvScripts/file-browser;
    };
}
