{
  buildFHSEnv,
  bedrock-on-linux-unwrapped,
  python3,
  coreutils,
  binutils-unwrapped,
  gnutar,
  xz,
  zstd,
  curl,
  xdg-utils,
  bubblewrap,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.tkinter
    ps.cryptography
  ]);
in
buildFHSEnv {
  pname = "bedrock-on-linux";
  inherit (bedrock-on-linux-unwrapped) version meta;

  targetPkgs = _: [
    bedrock-on-linux-unwrapped
    pythonEnv
    coreutils
    binutils-unwrapped
    gnutar
    xz
    zstd
    curl
    xdg-utils
    bubblewrap
  ];

  runScript = "${bedrock-on-linux-unwrapped}/bin/bedrock-on-linux";

  extraInstallCommands = ''
    ln -s ${bedrock-on-linux-unwrapped}/share $out/share
  '';

  passthru.unwrapped = bedrock-on-linux-unwrapped;
}
