{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  onnxruntime,
  makeWrapper,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "patent";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "r14dd";
    repo = "patent";
    rev = "v${version}";
    hash = "sha256-pkgC4z25Jdh7Erex0UJp/tM3t/QdZyp7YOcjB5qVcpM=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Prior-art search for your code ideas";
    homepage = "https://github.com/r14dd/patent";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "patent";
    platforms = lib.platforms.linux;
  };
}
