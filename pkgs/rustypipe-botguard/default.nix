{
  lib,
  fetchurl,
  rustPlatform,
  fetchFromGitea,
  nix-update-script,
  pkg-config,
  python3,
  openssl,
}:

let
  v8Version = "130.0.7";

  librusty_v8 = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v${v8Version}/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
    hash = "sha256-pkdsuU6bAkcIHEZUJOt5PXdzK424CEgTLXjLtQ80t10=";
  };

  escapedUrl = builtins.replaceStrings [ ":" "/" "." "-" ] [ "_" "_" "_" "_" ] librusty_v8.url;
in
rustPlatform.buildRustPackage rec {
  pname = "rustypipe-botguard";
  version = "0.1.2";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ThetaDev";
    repo = "rustypipe-botguard";
    rev = "v${version}";
    hash = "sha256-vUkTCRQvaH9hoaFNm2qgBZ4+f15wNBmctC/JDKF7W6E=";
  };

  cargoHash = "sha256-hPKjdP4X/iNNUlD8sjv7pKeRoDD8+Pj2xp1h8XOd/bs=";

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [ openssl ];

  preBuild = ''
    export HOME=$TMPDIR
    mkdir -p $HOME/.cargo/.rusty_v8
    ln -s ${librusty_v8} $HOME/.cargo/.rusty_v8/${escapedUrl}
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Run YouTube Botguard challenges and generate PO tokens";
    homepage = "https://codeberg.org/ThetaDev/rustypipe-botguard";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rustypipe-botguard";
    platforms = lib.platforms.linux;
  };
}
