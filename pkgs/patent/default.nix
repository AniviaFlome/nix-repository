{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  onnxruntime,
  makeWrapper,
  writeScript,
}:

rustPlatform.buildRustPackage rec {
  pname = "patent";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "r14dd";
    repo = "patent";
    rev = "v${version}";
    hash = "sha256-+PtRbyHXHPBh81rcKnK3WyYK3pPgGO7OUEMXBNOgRYI=";
  };

  # ponytail: fastembed default pulls ort download-binaries (fetches ONNX runtime at build time, breaks sandbox).
  # Switch to load-dynamic: dlopen libonnxruntime at runtime via ORT_DYLIB_PATH.
  postPatch = ''
    substituteInPlace Cargo.toml --replace \
      'fastembed = "5"' \
      'fastembed = { version = "5", default-features = false, features = [ "ort-load-dynamic", "hf-hub-native-tls", "image-models" ] }'
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ openssl ];

  # ponytail: rank tests download embedding model from HF, needs network at build time.
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/patent --set ORT_DYLIB_PATH ${lib.getLib onnxruntime}/lib/libonnxruntime.so
  '';

  # ponytail: nix-update regenerates Cargo.lock from the unpatched upstream Cargo.toml,
  # which drops libloading (needed by ort-load-dynamic). Apply the same feature patch
  # before generating the lockfile so the vendored crates match the build.
  passthru.updateScript = writeScript "update-patent" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix-update cargo

    set -euo pipefail

    cd "$(git rev-parse --show-toplevel)"

    # Bump version + src hash only (leave Cargo.lock to us)
    nix-update patent --src-only

    version=$(nix eval --raw .#patent.version 2>/dev/null || nix-instantiate --eval -E '(import ./. {}).patent.version' --raw)

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT
    git clone --depth 1 --branch "v$version" https://github.com/r14dd/patent "$tmpdir/src"

    # Apply the same feature patch as postPatch
    sed -i 's|fastembed = "5"|fastembed = { version = "5", default-features = false, features = [ "ort-load-dynamic", "hf-hub-native-tls", "image-models" ] }|' "$tmpdir/src/Cargo.toml"

    ( cd "$tmpdir/src" && cargo generate-lockfile )

    cp "$tmpdir/src/Cargo.lock" pkgs/patent/Cargo.lock
  '';

  meta = {
    description = "Prior-art search for your code ideas";
    homepage = "https://github.com/r14dd/patent";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "patent";
    platforms = lib.platforms.linux;
  };
}
