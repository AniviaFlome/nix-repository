# AGENTS.md

NUR-style nix package repository (not an official NUR repo). Packages in `pkgs/`, wired through `default.nix`, consumed as a flake input or overlay.

## Layout

- `default.nix` — entry point; every package added here via `pkgs.callPackage`
- `pkgs/<name>/default.nix` — one dir per package
- `pkgs/mpvScripts/` — nested attrset of mpv scripts (see below)
- `pkgs/hyprism/` — split: `unwrapped.nix` (binary) + `default.nix` (FHS wrapper); keep in sync
- `overlay.nix` — merges package set into nixpkgs; auto-merges attrsets (e.g. `mpvScripts`)
- `modules/`, `overlays/` — placeholders (just `default.nix` stubs)
- `ci.nix` — what CI builds/caches; filters by `meta.broken`, `meta.license.free`, `preferLocalBuild`
- `flake.nix` — exposes `packages`, `legacyPackages`, `formatter`, `checks`, `overlays.default`
- `scripts/update.py` + `scripts/get-update-targets.nix` — CI auto-update logic
- `maintainers/scripts/update.nix` — minimal shim implementing the nixpkgs file-mode update contract (`nix-shell ... --argstr package <attrpath>`), used by `nix-update --use-update-script` for all targets

## Commands

```sh
nix fmt          # format all files (treefmt: nixfmt, deadnix, statix, shfmt)
nix flake check  # verify formatting and pure package evaluations/tests
```

Always run `nix fmt` before committing.

## Updating a single package

```sh
nix shell nixpkgs#nix-update -c nix-update <attr-path> --use-update-script
```

Special cases (pass as extra args inside the package's `nix-update-script`):
- **Subpackages** — `waha-tui` needs `--subpackage=bunDeps`, `agent-device` passes `--subpackage=skill-*`, `agent-workspace-linux` passes `--subpackage=skillSrc`, `computer-use-linux` passes `--subpackage=cosmicSrc` and `--subpackage=skillSrc`
- **`0-unstable-*` / dated-branch versions** — `--version=branch`. Packages: `subtitle-sync`, `subtitle-translate`, `whisper-subs`, `cheatsheet`, `file-browser`, `artcnn`, `cmdui`, `sub-seek`, `keybind-visualizer`, `anilist-updater`, `reset-all`
- **Prerelease-only upstream (`--version=unstable`)** — `motrix-beta` (v2 line ships betas only; stable is still the years-old 1.x), `nuvio` (`*-alpha` releases), `mpv-translate` (`*-alpha.*` releases). Plain `nix-update` ignores prereleases, so the update script passes `--version=unstable`.
- **Prefixed/suffixed release tags (`--version-regex` + `--use-github-releases`)** — `proton-cachyos` (`cachyos-(.*)-slr`), `gdk-proton` (`release(.*)`), `soda` (`soda-(.*)`), `protosoda` (`protosoda-(.*)`). Always pass `--use-github-releases`: the default ATOM feed includes prereleases (e.g. `soda-*-experimental`) without a prerelease flag, and nix-update's unstable-keyword filter doesn't catch "experimental". `nectarlink` (to ignore `canary`/`v0.1.6-nightly.*` prereleases) and `bloomeetunes` (to ignore tag-only ATOM entries without release assets) also pass `--use-github-releases`. Flags live inside the package's own `nix-update-script`; the update runner executes them verbatim.
- **Prefixed skill tags** — `impeccable` tags releases as `skill-v<version>`, so the update script passes `--version-regex=skill-v(.*)`.
- **Custom update script** — `cake-wallet` uses a custom `writeShellScript` updater because upstream frequently publishes mobile-only releases without a Linux tarball or re-attaches an older Linux tarball under a newer tag; the script scans GitHub Releases for the newest `Cake_Wallet_v*_Linux.tar.xz` asset.

`adore`, `fallin`, and `hyprism` (FHS wrapper around `hyprism-unwrapped`) have no `updateScript` and are skipped by `scripts/get-update-targets.nix`. `adore` and `fallin` use `version = "latest"` with hardcoded model URLs.

## Package patterns

- **`mpvScripts.*`** — nested attrset in `default.nix` via `callMpvScript` helper, which passes `pkgs.mpvScripts.buildLua`.
- **Steam compat tools** (`proton-cachyos`, `gdk-proton`, `boson`, `nativecookie`) — not for profile install; use `programs.steam.extraCompatPackages`. `proton-cachyos` and `protosoda` expose a `steamcompattool` output; all have `preferLocalBuild = true`.
- **Agent skill packages** (`impeccable`, `caveman-skills`, `matt-pocock-skills`) — data-only derivations installing each skill to `$out/share/skills/<skill-name>` (`impeccable` also ships `$out/share/opencode-commands/impeccable.md`). No tests, no `mainProgram`.
- **`browse`** — a native Rust binary fetched from the per-platform npm tarballs (`@opencode/browse-<target>`, holding `bin/browse`); the `@opencode/browse` tarball is only a Node launcher. Upstream dropped the bundled `skills/browse` in 0.1.0 (guidance is served as MCP instructions instead), so it installs no `$out/share/skills` entry.

## Package documentation rule

When adding a package, you **must** add or update its row in the appropriate `README.md` package table in the same change.

## Adding a package

1. Create `pkgs/<name>/default.nix`
2. Add `pkgs.callPackage ./pkgs/<name> { … }` entry in `default.nix`
3. For prefixed/suffixed upstream tags: pass `extraArgs = [ "--version-regex=..." "--use-github-releases" ]` to `nix-update-script` (see special cases above)
4. For mpv scripts: add under `mpvScripts` via `callMpvScript`
5. Add a row to the matching table in `README.md` (Applications / Steam Compatibility Tools / MPV Shaders / MPV Scripts), using the real attr name as the label and upstream repo URL + `meta.description`
6. Add `passthru.tests` only where it catches real bugs (see "Tests" below) — not every package needs tests
7. Run `nix fmt` and `nix flake check`

## Removing a package

1. Delete `pkgs/<name>/` and drop its entry from `default.nix`
2. Remove its row from the matching table in `README.md`
3. Clean up any special-case notes above (update flags, unfree list in CI section, etc.) that referenced it

Keep `README.md` in sync whenever packages are added or removed — it is the user-facing package list.

## Tests

Tests are attached via `passthru.tests = { <name> = <derivation>; }` and run in two places:
- **`nix flake check`** — via `flake.nix` `checks` output (keys: `<pkg>-<testName>`, e.g. `nectarlink-version`, `browse-version`).
- **CI (`build.yml`)** — via `ci.nix`, which recurses `passthru.tests` of buildable packages (alongside the package itself) into `cacheOutputs` and Cachix.

Guidance — add tests where they add signal, not reflexively:
- **CLI binaries with a `--version` flag** — `testers.testVersion { package = finalAttrs.finalPackage; }` catches version-string regressions. Relies on `meta.mainProgram`; pass `command = "foo --version"` when the binary name differs from pname. Add `testers` to the derivation's arguments (callPackage injects it).
- **AppImages / prebuilt binaries / FHS wrappers / data packages / steam-compat tools** — no tests by default. A `test -x ${pkg}/bin/foo` smoke test is tautological (the build's installPhase already proved the file exists). Add a test only if there's a runtime behavior worth exercising.

When a derivation uses `rec { … }`, convert to `finalAttrs:` so tests can reference `finalAttrs.finalPackage`. Example:

```nix
passthru = {
  updateScript = nix-update-script { };
  tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
};
```

## CI

- `.github/workflows/build.yml` — `tests` job builds on `nixpkgs-unstable` + `nixos-unstable`, pushes to Cachix (`aniviaflome-nix-repository`), triggers NUR update for repo `aniviaflome` (running `nix-build-uncached ci.nix -A cacheOutputs`). A separate `checks` job (no Cachix upload) runs `nix flake check --no-build`, formatting check, `pytest scripts/test_update.py`, and builds `ci.nix -A mpvScriptOutputs`.
- `.github/workflows/update.yml` — daily `scripts/update.py --build --open-prs`, auto-commits successful direct updates with "pkgs: auto-update", writes a GitHub Step Summary, and fails the job if any package failed to update. The `--open-prs` flag proposes review-gated packages (`passthru.updatePr`) via GitHub PR instead of committing directly; no packages are currently review-gated, so it is a no-op. All targets with `passthru.updateScript` run uniformly in file mode (`default.nix` + `maintainers/scripts/update.nix`, with `NIXPKGS_ALLOW_UNFREE=1` set), avoiding Nix `lazy-trees` `--flake` store-path issues and verifying against `channel:nixos-unstable`. For local runs without `--build`, updates are fast but unverified.

## Dev shell

`shell.nix` provides `nix-init`, `nix-prefetch`, `nix-update`, `nurl`.
