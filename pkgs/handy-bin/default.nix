{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
}:

let
  pname = "handy-bin";
  version = "0.8.2";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    sha256 = "sha256-+rRePge3ts87RiqZDF9/af2MDP5OBWs8yJSTHPe1fKM=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/Handy.desktop $out/share/applications/handy.desktop
    cp -r ${appimageContents}/usr/share/icons $out/share
    substituteInPlace $out/share/applications/handy.desktop \
      --replace-warn 'Exec=AppRun' "Exec=$out/bin/${name}" \
      --replace-warn 'Exec=handy' "Exec=$out/bin/${name}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Handy: A handy desktop overlay for your hands";
    homepage = "https://github.com/cjpais/Handy";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
