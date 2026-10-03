{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  nix-update-script,
}:

let
  pname = "motrix";
  version = "2.0.0-beta.46";

  # Upstream names x86_64 AppImages `x86_64` but arm64 ones `arm64`.
  arch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64";
  hashes = {
    x86_64 = "sha256-nWsiOXy0jKpVTqJ4776ExCp40vAxA/cvnYqr7+XqNLU=";
    arm64 = "sha256-61jFyis781ajuC3FctQUCzNTa9DPbz7Q7kUPPEj9w30=";
  };

  src = fetchurl {
    url = "https://github.com/agalwood/Motrix/releases/download/v${version}/Motrix-${version}-${arch}.AppImage";
    hash = hashes.${arch};
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/motrix.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/motrix.desktop \
      --replace-warn 'Exec=AppRun' 'Exec=motrix'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  # Upstream only ships prereleases on the v2 line (stable is still 1.x
  # from years ago), so the updater must follow unstable versions.
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=unstable" ]; };

  meta = with lib; {
    description = "A full-featured open-source download manager";
    homepage = "https://motrix.app";
    changelog = "https://github.com/agalwood/Motrix/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "motrix";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
