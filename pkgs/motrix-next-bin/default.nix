{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  nix-update-script,
}:

let
  pname = "motrix-next-bin";
  version = "3.8.4";

  arch = if stdenv.hostPlatform.isAarch64 then "aarch64" else "amd64";

  src = fetchurl {
    url = "https://github.com/AnInsomniacy/motrix-next/releases/download/v${version}/MotrixNext_${version}_${arch}.AppImage";
    hash = "sha256-q8R/VPX4c+F+rLzQOF7n5pRORx5YwTyR4K/zC4lxRcU=";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A full-featured open-source download manager";
    homepage = "https://github.com/AnInsomniacy/motrix-next";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "motrix-next-bin";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
