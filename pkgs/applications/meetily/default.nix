{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  pnpm_9,
  nodejs,
  pkg-config,
  wrapGAppsHook4,
  openssl,
  webkitgtk_4_1,
  glib-networking,
  libsoup_3,
  alsa-lib,
  libpulseaudio,
  ffmpeg,
  sqlite,
  cmake,
  clang,
  llvmPackages,
}:
rustPlatform.buildRustPackage rec {
  pname = "meetily";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Zackriya-Solutions";
    repo = "meeting-minutes";
    rev = version;
    hash = lib.fakeHash;
  };

  sourceRoot = "${src.name}/frontend";

  pnpmDeps = pnpm_9.fetchDeps {
    inherit
      pname
      version
      src
      sourceRoot
      ;
    hash = lib.fakeHash;
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = cargoRoot;

  cargoHash = lib.fakeHash;

  nativeBuildInputs = [
    cargo-tauri.hook
    pnpm_9.configHook
    nodejs
    pkg-config
    wrapGAppsHook4
    cmake
    clang
    llvmPackages.libclang
  ];

  buildInputs = [
    openssl
    sqlite
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    webkitgtk_4_1
    glib-networking
    libsoup_3
    alsa-lib
    libpulseaudio
  ];

  env = {
    LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
    OPENSSL_NO_VENDOR = 1;
  };

  postInstall = ''
    wrapProgram $out/bin/meetily \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = {
    description = "Privacy-first AI meeting assistant with local transcription and summarization";
    homepage = "https://github.com/Zackriya-Solutions/meeting-minutes";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "meetily";
  };
}
