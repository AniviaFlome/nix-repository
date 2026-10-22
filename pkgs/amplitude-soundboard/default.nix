{
  lib,
  fetchurl,
  appimageTools,
  nix-update-script,
  runCommand,
  stdenv,
  makeWrapper,
  python3,
}:

let
  pname = "amplitude-soundboard";
  version = "2.15.1";

  src = fetchurl {
    url = "https://github.com/dan0v/AmplitudeSoundboard/releases/download/${version}/Amplitude_Soundboard-x86_64.AppImage";
    hash = "sha256-e09RC0FExzMJSKRgqsf6yY2+/Eud8uashbmhohsCq6U=";
  };

  bassShim = runCommand "amplitude-bass-shim" { nativeBuildInputs = [ stdenv.cc ]; } ''
    mkdir -p $out/lib
    $CC -shared -fPIC -O2 -o $out/lib/libbass-shim.so ${./bass-plugin-shim.c} -ldl
  '';

  unpatchedContents = appimageTools.extract {
    inherit pname version src;
  };

  appimageContents = runCommand "${pname}-contents" { nativeBuildInputs = [ python3 ]; } ''
    cp -r ${unpatchedContents} $out
    chmod -R +w $out
    python3 ${./disable-update-check.py} $out/usr/bin/amplitude_soundboard.dll
  '';
in
appimageTools.wrapAppImage {
  inherit pname version src;
  contents = appimageContents;

  extraPkgs = pkgs: [
    pkgs.icu
    pkgs.libinput
  ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/amplitude_soundboard.desktop $out/share/applications/amplitude_soundboard.desktop
    install -Dm444 ${appimageContents}/icn.png $out/share/icons/hicolor/512x512/apps/icn.png
    substituteInPlace $out/share/applications/amplitude_soundboard.desktop \
      --replace-warn 'Exec=amplitude_soundboard' 'Exec=${pname}'

    . ${makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/${pname} \
      --set LD_PRELOAD ${bassShim}/lib/libbass-shim.so
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A sleek, cross-platform soundboard";
    homepage = "https://github.com/dan0v/AmplitudeSoundboard";
    license = licenses.gpl3Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "amplitude-soundboard";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
