{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  nix-update-script,
}:

let
  pname = "motrix-next";
  version = "3.9.5";

  arch = if stdenv.hostPlatform.isAarch64 then "aarch64" else "amd64";

  src = fetchurl {
    url = "https://github.com/AnInsomniacy/motrix-next/releases/download/v${version}/MotrixNext_${version}_${arch}.AppImage";
    hash = "sha256-XIgOQedutD0O/Ow2lqxcP8CzCVhnL+EzkNXa7WZ15dQ=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/MotrixNext.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A full-featured open-source download manager";
    homepage = "https://github.com/AnInsomniacy/motrix-next";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "motrix-next";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
