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

  proton-cachyos = pkgs.callPackage ./pkgs/proton-cachyos {
    inherit (lib) makeReleaseUpdater;
  };
  waha-tui = pkgs.callPackage ./pkgs/waha-tui { };
  waytator = pkgs.callPackage ./pkgs/waytator { };
  torrra = pkgs.callPackage ./pkgs/torrra { };
  turkanime-cli = pkgs.callPackage ./pkgs/turkanime-cli { };
  anitr-cli = pkgs.callPackage ./pkgs/anitr-cli { };
  turkanime-gui = pkgs.callPackage ./pkgs/turkanime-gui { };
  nativecookie = pkgs.callPackage ./pkgs/nativecookie { };
  osu-beatmap-manager-git = pkgs.callPackage ./pkgs/osu-beatmap-manager-git { };
  boson = pkgs.callPackage ./pkgs/boson { };
  cake-wallet = pkgs.callPackage ./pkgs/cake-wallet { };
  gdk-proton = pkgs.callPackage ./pkgs/gdk-proton { inherit (lib) makeReleaseUpdater; };
  getcomics-downloader = pkgs.callPackage ./pkgs/getcomics-downloader { };
  handy = pkgs.callPackage ./pkgs/handy { };
  hyprism-unwrapped = pkgs.callPackage ./pkgs/hyprism/unwrapped.nix { };
  hyprism = pkgs.callPackage ./pkgs/hyprism {
    hyprism-unwrapped = pkgs.callPackage ./pkgs/hyprism/unwrapped.nix { };
  };
  artcnn = pkgs.callPackage ./pkgs/artcnn { };
  fallin = pkgs.callPackage ./pkgs/fallin { };
  adore = pkgs.callPackage ./pkgs/adore { };
  crankshaft = pkgs.callPackage ./pkgs/crankshaft { };
  motrix-next = pkgs.callPackage ./pkgs/motrix-next { };
  bloomeetunes = pkgs.callPackage ./pkgs/bloomeetunes { };
  amplitude-soundboard = pkgs.callPackage ./pkgs/amplitude-soundboard { };
  cmdui = pkgs.callPackage ./pkgs/cmdui { };

  bedrock-on-linux-unwrapped = pkgs.callPackage ./pkgs/bedrock-on-linux/unwrapped.nix { };
  bedrock-on-linux = pkgs.callPackage ./pkgs/bedrock-on-linux {
    bedrock-on-linux-unwrapped = pkgs.callPackage ./pkgs/bedrock-on-linux/unwrapped.nix { };
  };

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
      mpv-translate = callMpvScript ./pkgs/mpvScripts/mpv-translate;
      subtitle-sync = callMpvScript ./pkgs/mpvScripts/subtitle-sync;
      whisper-subs = callMpvScript ./pkgs/mpvScripts/whisper-subs;
      cheatsheet = callMpvScript ./pkgs/mpvScripts/cheatsheet;
      file-browser = callMpvScript ./pkgs/mpvScripts/file-browser;
    };
}
