{
  lib,
  stdenvNoCC,
  fetchurl,
  python3,
  makeWrapper,
  binutils-unwrapped,
  gnutar,
  zstd,
  xdg-utils,
  curl,
  nix-update-script,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.tkinter
    ps.cryptography
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bedrock-on-linux-unwrapped";
  version = "2.2.3";

  src = fetchurl {
    url = "https://github.com/Wyze3306/BedrockOnLinux/releases/download/v${finalAttrs.version}/bedrock-on-linux_${finalAttrs.version}_amd64.deb";
    hash = "sha256-NozITtfHzDJKJKVUR6d7piefYvE2dFmBXA8op/ef2rI=";
  };

  nativeBuildInputs = [
    binutils-unwrapped
    gnutar
    zstd
    makeWrapper
  ];

  buildInputs = [ ];

  unpackPhase = ''
    ar x $src
    tar -xf data.tar.zst
  '';

  installPhase = ''
    libdir=$out/lib/bedrock-on-linux
    mkdir -p $libdir $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

    cp -r usr/lib/bedrock-on-linux/bol $libdir/
    cp -r usr/lib/bedrock-on-linux/customtkinter $libdir/
    cp -r usr/lib/bedrock-on-linux/darkdetect $libdir/
    cp -r usr/lib/bedrock-on-linux/packaging $libdir/
    cp usr/lib/bedrock-on-linux/bedrock-on-linux $libdir/
    cp -r usr/lib/bedrock-on-linux/data $libdir/

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/bedrock-on-linux \
      --set PYTHONPATH "$libdir" \
      --prefix PATH : "${
        lib.makeBinPath [
          curl
          gnutar
          zstd
          xdg-utils
        ]
      }" \
      --add-flags "$libdir/bedrock-on-linux"

    install -Dm644 usr/share/applications/bedrock-on-linux.desktop $out/share/applications/bedrock-on-linux.desktop
    install -Dm644 usr/share/icons/hicolor/256x256/apps/bedrock-on-linux.png $out/share/icons/hicolor/256x256/apps/bedrock-on-linux.png
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^v(\\d+\\.\\d+\\.\\d+)$" ];
  };

  meta = with lib; {
    description = "Run Minecraft Bedrock (Windows GDK) on Linux, multiplayer included";
    homepage = "https://github.com/Wyze3306/BedrockOnLinux";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "bedrock-on-linux";
    platforms = [ "x86_64-linux" ];
  };
})
