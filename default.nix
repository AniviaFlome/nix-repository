{ pkgs ? import <nixpkgs> { } }:

{
  mpvScripts = {
    whisper-subs = pkgs.callPackage ./packages/whisper-subs { };
    interSubs = pkgs.callPackage ./packages/interSubs { };
  };
}
