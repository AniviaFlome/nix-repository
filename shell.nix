{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    nix-init
    nix-prefetch
    nix-update
    nurl
  ];
}
