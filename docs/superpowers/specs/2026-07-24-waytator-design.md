# Design: package `waytator` for the NUR-style repository

Date: 2026-07-24
Upstream: https://github.com/faetalize/waytator
Latest tag: `v1.2.4`

## Goal

Add `waytator` — a GTK4 + libadwaita screenshot annotator and lightweight image
editor written in C and built with meson — as a new package in this repository,
wired through `default.nix` and consumable via the flake `packages` output.

## Upstream summary

- Language: C (c11)
- Build system: meson + ninja, uses the `gnome` meson module
  (`gnome.compile_resources` for the bundled gresource).
- Declared deps (from `meson.build` / `src/meson.build`):
  - `gtk4` >= 4.10
  - `libadwaita-1` >= 1.6
  - `m` (libm, glibc)
- Installs:
  - `waytator` binary
  - `dev.faetalize.waytator.desktop` into `${datadir}/applications`
  - PNG icons (128/256/512) into hicolor icon dirs
  - No `gnome.post_install()` call, so no `gtk-update-icon-cache` /
    `update-desktop-database` required at build time.
- Optional runtime deps called out in the README:
  - `tesseract` for OCR
  - `wl-clipboard` for niri screenshot clipboard integration
- License: GPL-3.0-or-later
- Releases are tagged `v<version>` (e.g. `v1.2.4`).

## Design decisions (confirmed with user)

1. **Version tracking**: tagged releases. `fetchFromGitHub` with
   `rev = "refs/tags/v${version}"`, version `1.2.4` (strip leading `v`).
   `passthru.updateScript = nix-update-script { };` with no extra args —
   default tag-based nix-update flow.
2. **Bundle optional runtime deps**: both `tesseract4` and `wl-clipboard`
   are added to the derivation's runtime closure so the headline features
   (OCR, niri clipboard integration) work out of the box.

## Package layout

Single derivation, no split:

```
pkgs/waytator/default.nix
```

## Derivation shape

```nix
{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook4,
  glib,
  gtk4,
  libadwaita,
  tesseract4,
  wl-clipboard,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "waytator";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "faetalize";
    repo = "waytator";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = lib.fakeHash; # filled on first build
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    glib # glib-compile-resources for gnome.compile_resources
  ];

  buildInputs = [
    gtk4
    libadwaita
    tesseract4
    wl-clipboard
  ];

  mesonBuildType = "release";

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Screenshot annotator and lightweight image editor";
    homepage = "https://github.com/faetalize/waytator";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "waytator";
    platforms = platforms.linux;
  };
})
```

Notes on the shape:
- `stdenv.mkDerivation` (not `stdenvNoCC`) — C compilation.
- `wrapGAppsHook4` to get the GTK4 gsettings schemas / environment vars
  on the wrapped binary at runtime.
- `glib` in `nativeBuildInputs` provides `glib-compile-resources`, which
  the meson `gnome` module invokes during `gnome.compile_resources`.
- `tesseract4` and `wl-clipboard` in `buildInputs` so they end up on
  PATH via `wrapGAppsHook4`'s environment wrapping and in the closure.
- `mesonBuildType = "release"` matches the README's
  `meson setup build --buildtype=release`.
- Uses the `finalAttrs:` style already present in the repo (see `cmdui`).
- `lib.fakeHash` placeholder is replaced with the real hash after the
  first `nix build` (nix-update / nix will report the correct value).

## Wiring

In `default.nix`, add (placed after `waha-tui` for rough grouping):

```nix
waytator = pkgs.callPackage ./pkgs/waytator { };
```

No `inherit (lib) makeReleaseUpdater;` needed — this package uses plain
`nix-update-script`, not the `makeReleaseUpdater` helper.

## CI / overlay implications

- `ci.nix` auto-discovers derivations from `default.nix`; no changes
  needed. `waytator` is free-license and not `preferLocalBuild`, so it
  will be built and cached by CI.
- `overlay.nix` merges the attrset into nixpkgs; `waytator` does not
  collide with any existing nixpkgs attr, so it is injected directly.
- `flake.nix` exposes it via `legacyPackages` / `packages` automatically.

## Verification

1. `nix fmt` — format the new file.
2. `nix build .#waytator` — succeeds, produces a working binary.
3. Run the built binary to confirm it launches (e.g. `./result/bin/waytator
   --help` or version output; if it has no such flag, launching it in a
   headless Wayland session is impractical, so a successful link/build is
   the practical gate).
4. `nix flake check` — formatting + evaluation check passes.
5. Update the `hash` from `lib.fakeHash` to the real value reported by
   the first failed build.

## Out of scope

- NixOS / home-manager module for the niri screenshot keybind integration
  (the upstream ships `scripts/screenshot-to-waytator.sh`). Could be a
  follow-up in `modules/` if desired later.
- Packaging the helper shell script separately. It is not installed by
  meson and is out of scope for this derivation.