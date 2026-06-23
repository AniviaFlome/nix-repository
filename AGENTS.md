# AGENTS.md

NUR-style nix package repository (not an official NUR repo). Packages in `pkgs/`, wired through `default.nix`, consumed as a flake input or overlay.

## Layout

- `default.nix` — entry point; every package added here via `pkgs.callPackage`
- `pkgs/<name>/default.nix` — one dir per package
- `pkgs/mpvScripts/` — nested attrset of mpv scripts (see below)
- `pkgs/hyprism/` — split: `unwrapped.nix` (binary) + `default.nix` (FHS wrapper); keep in sync
- `lib/default.nix` — `makeReleaseUpdater` helper
- `overlay.nix` — merges package set into nixpkgs; auto-merges attrsets (e.g. `mpvScripts`)
- `modules/`, `overlays/` — placeholders (just `default.nix` stubs)
- `ci.nix` — what CI builds/caches; filters by `meta.broken`, `meta.license.free`, `preferLocalBuild`
- `flake.nix` — exposes `packages`, `legacyPackages`, `formatter`, `checks`, `overlays.default`
- `scripts/update.py` + `scripts/get-update-targets.nix` — CI auto-update logic

`pkgs/rice-cooker/` and `pkgs/ai-skills-bundle/` are empty, not wired in.

## Commands

```sh
nix fmt          # format all files (treefmt: nixfmt, deadnix, statix, shfmt)
nix flake check  # verify formatting
```

Always run `nix fmt` before committing.

## Updating a single package

```sh
nix shell nixpkgs#nix-update -c nix-update --flake <attr-path>
```

Special cases (pass as extra args):
- **Subpackages** — `waha-tui` needs `--subpackage=bunDeps`
- **`0-unstable-*` / dated-branch versions** — `--version=branch`. Packages: `interSubs`, `subtitle-sync`, `whisper-subs`, `cheatsheet`, `file-browser`, `artcnn`, `sldl-tui`, `fallin`
- **`makeReleaseUpdater` packages** — `proton-cachyos`, `gdk-proton`. Updater in `lib/default.nix` fetches latest GitHub/Gitea release tag. CI runs these via `--use-update-script`.

`adore` and `fallin` use `version = "latest"` and `--version=branch` — no real version pinned.

## Package patterns

- **`mpvScripts.*`** — nested attrset in `default.nix` via `callMpvScript` helper, which passes `pkgs.mpvScripts.buildLua`.
- **Steam compat tools** (`proton-cachyos`, `gdk-proton`, `boson`, `nativecookie`) — provide a `steamcompattool` output; not for profile install. Use `programs.steam.extraCompatPackages`. All have `preferLocalBuild = true`.
- **`nativecookie`** — uses plain `[ nix-update ]` as `updateScript` (list form), not `nix-update-script` helper.

## Adding a package

1. Create `pkgs/<name>/default.nix`
2. Add `pkgs.callPackage ./pkgs/<name> { … }` entry in `default.nix`
3. Pass `inherit (lib) makeReleaseUpdater;` if using the release updater
4. For mpv scripts: add under `mpvScripts` via `callMpvScript`
5. Run `nix fmt` and `nix flake check`

## CI

- `.github/workflows/build.yml` — builds on `nixpkgs-unstable` + `nixos-unstable`, pushes to Cachix (`aniviaflome-nix-repository`), triggers NUR update for repo `aniviaflome`. Runs `nix-build-uncached ci.nix -A cacheOutputs`.
- `.github/workflows/update.yml` — daily `scripts/update.py`, auto-commits with "pkgs: auto-update".

## Dev shell

`shell.nix` provides `nix-init`, `nix-prefetch`, `nix-update`, `nurl`.