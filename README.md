# Nix Repository

My nix packages repository.

## Packages

### Applications

| Package | Description |
|---------|-------------|
| [dwproton](https://dawn.wine/dawn-winery/dwproton) | Proton builds with Dawn Winery fixes for Genshin Impact, Zenless Zone Zero, etc. (Steam compatibility tool) |
| [proton-cachyos](https://github.com/CachyOS/proton-cachyos) | CachyOS optimized Proton with x86_64_v3 optimizations, DXVK-Sarek, FSR4, NTSync (Steam compatibility tool) |
| [turkanime-cli](https://github.com/KebabLord/turkanime-indirici) | Türk Anime python library and downloader |
| [torrra](https://github.com/stabldev/torrra) | A Python CLI tool to search and download torrents |
| [waha-tui](https://github.com/muhammedaksam/waha-tui) | A beautiful TUI for WhatsApp using WAHA (WhatsApp HTTP API) |

### MPV Scripts

| Package | Description |
|---------|-------------|
| [mpvScripts.interSubs](https://github.com/oltodosel/interSubs) | Interactive subtitles for MPV |
| [mpvScripts.whisper-subs](https://github.com/GhostNaN/whisper-subs) | MPV lua script to generate subtitles at runtime with whisper.cpp |
| [mpvScripts.subtitle-sync](https://github.com/AniviaFlome/mpv-scripts) | MPV script to mark subtitle start times and calculate differences |

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

Then packages are available as `pkgs.dwproton`, `pkgs.mpvScripts.interSubs`, etc.

### Install packages directly (without overlay)

#### In NixOS configuration

```nix
environment.systemPackages = [
  inputs.nix-repository.legacyPackages.${pkgs.stdenv.hostPlatform.system}.waha-tui
];
```
