# Nix Repository

My nix packages repository.

## Packages

- **interSubs**: [interSubs](https://github.com/oltodosel/interSubs) - Interactive subtitles for MPV.
- **waha-tui**: [waha-tui](https://github.com/muhammedaksam/waha-tui) - A beautiful Terminal User Interface for WhatsApp using WAHA (WhatsApp HTTP API).
- **whisper-subs**: [WhisperSubs](https://github.com/GhostNaN/whisper-subs) - MPV lua script to generate subtitles at runtime with whisper.cpp.

## Usage

### Binary Cache (Cachix)

This repository uses [Cachix](https://cachix.org) to provide pre-built binaries.

#### Using with nix.settings (flakes)

```nix
{
  nix.settings = {
    substituters = [ "https://aniviaflome-nix-repository.cachix.org" ];
    trusted-public-keys = [ "aniviaflome-nix-repository.cachix.org-1:P+CE5AN1cNlYCvfAr/8xbKpD3MjdL1ZL9OiA5HJSBBo=" ];
  };
}
```

### Add as flake input

```nix
{
  inputs.nix-repository.url = "github:AniviaFlome/nix-repository";
}
```

### Use as an overlay

```nix
nixpkgs.overlays = [ inputs.nix-repository.overlays.default ];
```

Then packages are available as , `pkgs.mpvScripts.interSubs`, etc.

### Install packages directly (without overlay)

#### In NixOS configuration

```nix
environment.systemPackages = [
  inputs.nix-repository.legacyPackages.${pkgs.stdenv.hostPlatform.system}.waha-tui
];
```
