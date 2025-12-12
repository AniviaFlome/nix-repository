# Nix Repository

My nix packages repository.

## Packages

- **whisper-subs**: [WhisperSubs](https://github.com/GhostNaN/whisper-subs) - MPV lua script to generate subtitles at runtime with whisper.cpp.
- **inter-subs**: [interSubs](https://github.com/oltodosel/interSubs) - Interactive subtitles for MPV.
- **meetily**: [Meetily](https://github.com/Zackriya-Solutions/meeting-minutes) - Privacy-first AI meeting assistant with local transcription and summarization.

## Usage

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

Then packages are available as `pkgs.meetily`, `pkgs.mpvScripts.interSubs`, etc.

### Install packages directly (without overlay)

#### In NixOS configuration

```nix
environment.systemPackages = [
  inputs.nix-repository.legacyPackages.${pkgs.stdenv.hostPlatform.system}.applications.meetily
];
```
