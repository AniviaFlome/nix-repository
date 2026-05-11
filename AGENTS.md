# AGENTS.md

## Commands

```bash
# Format and lint all Nix + shell files
nix fmt

# Check formatting without modifying files
nix flake check

# Build a single package
nix build .#<package-name>

# Run the generic auto-updater (uses nix-update for all packages except excluded ones)
python3 ./scripts/update.py

# Run the mirrored-build updater (wizard101, crystal-realms)
bash ./scripts/update-mirrored.sh

# Run update script tests
pytest scripts/test_update.py
```

## Formatting

`treefmt.nix` runs `nixfmt`, `deadnix`, `statix`, and `shfmt`. Always run `nix fmt` before committing Nix or shell changes.

## Repository structure

- **`pkgs/<name>/default.nix`** — each package is a self-contained directory
- **`default.nix`** — central registry; every package must be added here with `pkgs.callPackage`
- **`lib/default.nix`** — exports `makeReleaseUpdater`, a helper for packages that track GitHub/Gitea releases
- **`ci.nix`** — filters `default.nix` for buildable + cacheable derivations (skips `broken`, `unfree`, `preferLocalBuild`)
- **`overlay.nix`** — auto-merges attr sets (e.g. `mpvScripts`) with existing nixpkgs attrs

## Adding a new package

1. Create `pkgs/<name>/default.nix`
2. Add entry to `default.nix` via `pkgs.callPackage ./pkgs/<name> { ... }`
3. If it needs `makeReleaseUpdater`, pass `inherit (lib) makeReleaseUpdater`
4. Run `nix fmt` then `nix build .#<name>`

## Update system

- **`scripts/update.py`** — iterates all packages via `scripts/get-update-targets.nix`, runs `nix-update` on each. Runs daily via `update.yml` workflow.
- **`scripts/get-update-targets.nix`** — has a `skipPackages` list. Packages in this list are excluded from the generic updater. Add packages here if they have their own update workflow.
- **`scripts/update-mirrored.sh`** — handles packages with fixed upstream URLs (where the URL doesn't change on update). Downloads, compares hashes, uploads dated assets to a single GitHub release (`appimages` tag), and updates version+hash in Nix files. Packages are defined in a `PACKAGES` array as `"name|url|nix/path"`. Runs daily via `update-mirrored.yml`.

## Key conventions

- Package names use `-bin` suffix for prebuilt binaries, `-git` for HEAD builds, no suffix for source builds
- `meta.license` must be set — `ci.nix` skips packages where `license.free` is false
- Packages that should not be cached (e.g. proton tools) set `preferLocalBuild = true`
- The `inputs` attr in `flake.nix` is passed through to `default.nix` but currently unused
