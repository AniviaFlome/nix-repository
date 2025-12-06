# Nix Repository

My nix packages repository.

## Packages

- **whisper-subs**: [WhisperSubs](https://github.com/GhostNaN/whisper-subs) - MPV lua script to generate subtitles at runtime with whisper.cpp.
- **inter-subs**: [interSubs](https://github.com/oltodosel/interSubs) - Interactive subtitles for MPV.

## Usage

### Use as an overlay

```nix
nixpkgs.overlays = [ nix-repository.overlays.default ];
```