{
  lib,
  stdenv,
  requireFile,
  autoPatchelfHook,
  makeWrapper,
  SDL2,
  alsa-lib,
  libGL,
  libX11,
  libXcursor,
  libXinerama,
  libXrandr,
  libXi,
  libXext,
  libxkbcommon,
  wayland,
  vulkan-loader,
  udev,
  pulseaudio,
}:
let
  maintainers = import ../../maintainers.nix;
in
stdenv.mkDerivation rec {
  pname = "crystal-realms";
  version = "1.9.4-alpha";

  src = requireFile {
    name = "crystal_realms_linux_x86.tar.gz";
    message = ''
      Crystal Realms must be downloaded manually from itch.io.

      1. Go to https://marcomeijer.itch.io/crystalrealms
      2. Download "crystal_realms_linux_x86.tar.gz" for Linux
      3. Add the file to the Nix store:

         nix-store --add-fixed sha256 crystal_realms_linux_x86.tar.gz
    '';
    # Use `nix --extra-experimental-features nix-command hash file --sri --type sha256` to get the correct hash
    hash = "sha256-G0WebPZSYvs0kzJw0PoykpBfOoc27jhZ5TMuWrgqDHg=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    SDL2
    alsa-lib
    libGL
    libX11
    libXcursor
    libXinerama
    libXrandr
    libXi
    libXext
    libxkbcommon
    wayland
    vulkan-loader
    udev
    pulseaudio
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/crystal-realms
    cp -r * $out/share/crystal-realms/

    chmod +x $out/share/crystal-realms/crystal_realms
    makeWrapper $out/share/crystal-realms/crystal_realms $out/bin/crystal-realms \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --chdir "$out/share/crystal-realms"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A 2D sandbox MMO game where you can gather resources, create worlds, engage in combat, complete quests, and craft items";
    homepage = "https://marcomeijer.itch.io/crystalrealms";
    license = licenses.unfree;
    maintainers = [ maintainers.aniviaflome ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
