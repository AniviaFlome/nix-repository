# AGENTS.md

## Project structure

This is a NUR-style nix package repository (not an official NUR repo but follows the pattern). Packages are defined in `pkgs/` and wired through `default.nix`. Consumers use it as a flake input or overlay.

- `default.nix` — entry point; every new package must be added here with `pkgs.callPackage`
- `pkgs/` — one directory per package, each with a `default.nix`
- `lib/default.nix` — shared helpers (currently `makeReleaseUpdater`)
- `overlay.nix` — merges package set into nixpkgs; auto-merges attrsets (e.g. `mpvScripts`)
- `modules/`, `overlays/` — placeholders for NixOS modules and extra overlays
- `ci.nix` — determines what CI builds and caches (filters by `meta.broken`, `meta.license.free`, `preferLocalBuild`)

### Unfinished packages

`pkgs/rice-cooker/` and `pkgs/ai-skills-bundle/` are empty directories — not wired into `default.nix`.

## Formatting and linting

Formatted by `treefmt.nix` using **nixfmt**, **deadnix**, **statix**, and **shfmt**:

```
nix fmt          # format all files
nix flake check  # verify formatting (and any other checks)
```

Always run `nix fmt` before committing Nix changes.

## Updating packages

### Automated (CI)

`.github/workflows/update.yml` runs `scripts/update.py` daily, which iterates all flake packages and calls `nix-update --flake` per package. Packages with `passthru.updateScript` get `--use-update-script`.

### Manual — single package

```sh
nix shell nixpkgs#nix-update -c nix-update --flake <attr-path>
```

For packages with `--subpackage` flags (e.g. `waha-tui` has `bunDeps`):

```sh
nix-update --flake waha-tui --subpackage bunDeps
```

For packages using `makeReleaseUpdater` (e.g. `dwproton-bin`, `proton-cachyos-bin`, `boson-bin`, `gdk-proton-bin`, `nativecookie-bin`), the update script is in `lib/default.nix` and fetches the latest GitHub/Gitea release tag.

For the `0-unstable-*` versioned packages (e.g. `interSubs`):

```sh
nix-update --flake <attr-path> --version=branch
```

## Package patterns

- **`mpvScripts.*`** — nested attrset in `default.nix`. Each script needs `pkgs.mpvScripts.buildLua` passed in, done via the `callMpvScript` helper.
- **`hyprism`** — split into `unwrapped.nix` (the binary) and `default.nix` (FHS wrapper). Both must be kept in sync.
- **Steam compat tools** (`dwproton-bin`, `proton-cachyos-bin`, `boson-bin`, `gdk-proton-bin`, `nativecookie-bin`) — use `steamcompattool` output; not meant to be installed into profiles. Use `programs.steam.extraCompatPackages`.
- **Packages with `preferLocalBuild = true`** — excluded from CI cache via `ci.nix`.

## Adding a new package

1. Create `pkgs/<name>/default.nix`
2. Add entry in `default.nix` with `pkgs.callPackage ./pkgs/<name> { … }`
3. Pass `inherit (lib) makeReleaseUpdater;` if the package needs the custom release updater
4. Run `nix fmt` and `nix flake check`

## CI

`.github/workflows/build.yml` builds on `nixpkgs-unstable` and `nixos-unstable`, pushes to Cachix (`aniviaflome-nix-repository`). It also triggers NUR update for repo `aniviaflome`.

## Dev shell

`shell.nix` provides: `nix-init`, `nix-prefetch`, `nix-update`, `nurl`.