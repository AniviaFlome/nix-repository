# Nix Repository

My nix packages repository.

## Packages

### Applications

| Package | Description |
|---------|-------------|
| [anitr-cli](https://github.com/axrona/anitr-cli) | Terminalde Türkçe altyazılı anime arama ve izleme aracı |
| [cake-wallet-bin](https://github.com/cake-tech/cake_wallet) | A non-custodial multi-currency wallet |
| [getcomics-downloader](https://github.com/UlucKaymak/getcomics-downloader) | A TUI-based CLI tool to search for and download comics from getcomics.info |
| [handy](https://github.com/cjpais/Handy) | A free, open source, and extensible speech-to-text application that works completely offline. |
| [hyprism](https://github.com/HyPrismTeam/HyPrism) | Hytale launcher with mod management, and more! |
| [osu-beatmap-manager](https://github.com/AniviaFlome/osu-beatmap-manager) | osu! Beatmap Manager |
| [torrra](https://github.com/stabldev/torrra) | A Python CLI tool to search and download torrents |
| [turkanime-cli](https://github.com/KebabLord/turkanime-indirici) | Türk Anime python kütüphanesi ve tarayıcısı |
| [turkanime-gui](https://github.com/barkeser2002/turkanime-gui) | Türkanime video oynatıcı ve indirici (GUI) |
| [waha-tui](https://github.com/muhammedaksam/waha-tui) | A beautiful TUI for WhatsApp using WAHA (WhatsApp HTTP API) |

### Steam Compatibility Tools

| Package | Description |
|---------|-------------|
| [boson](https://github.com/FyraLabs/boson) | Run Electron Steam games natively on Linux* |
| [dwproton](https://dawn.wine/dawn-winery/dwproton) | Proton builds with Dawn Winery fixes for Genshin Impact, Zenless Zone Zero, etc. |
| [gdk-proton](https://github.com/Weather-OS/GDK-Proton) | WineGDK Protonified |
| [nativecookie](https://github.com/Kesefon/NativeCookie) | Run Cookie Clicker Steam edition with native Electron on Linux |
| [proton-cachyos](https://github.com/CachyOS/proton-cachyos) | Compatibility tool for Steam Play based on Wine and additional components  |

### MPV Shaders

| Package | Description |
|---------|-------------|
| [artcnn](https://github.com/Artoriuz/ArtCNN) | ArtCNN shaders for MPV |
| [fallin](https://github.com/renarchi/Re-SISR) | A collection of custom Super-Resolution models and restoration experiments. |

### MPV Scripts

| Package | Description |
|---------|-------------|
| [mpvScripts.cheatsheet](https://github.com/AniviaFlome/mpv-scripts/tree/main/cheatsheet) | MPV cheatsheet script showing keybindings in an interactive overlay |
| [mpvScripts.file-browser](https://github.com/CogentRedTester/mpv-file-browser) | A simple no-dependency file browser for mpv player |
| [mpvScripts.interSubs](https://github.com/oltodosel/interSubs) | Interactive subtitles for MPV |
| [mpvScripts.subtitle-sync](https://github.com/AniviaFlome/mpv-scripts) | MPV script to mark subtitle start times and calculate the difference between them |
| [mpvScripts.whisper-subs](https://github.com/GhostNaN/whisper-subs) | WhisperSubs is a mpv lua script to generate subtitles at runtime with whisper.cpp on Linux |

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
