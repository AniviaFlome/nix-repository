{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  killall,
  nix-update-script,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      pyqt5
      numpy
      beautifulsoup4
      requests
      lxml
      httpx
    ]
  );
in
buildLua {
  pname = "interSubs";
  version = "unstable-2025-03-18";

  src = fetchFromGitHub {
    owner = "oltodosel";
    repo = "interSubs";
    rev = "a4113586db8f60f1c533f717c1c1a928f3723049";
    hash = "sha256-t30fEbpzKO7AkYv403QVP+T84g5XWLysS8k5W9CX4XY=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts
    install -m644 interSubs.lua interSubs.py interSubs_config.py $out/share/mpv/scripts/

    substituteInPlace $out/share/mpv/scripts/interSubs.lua \
      --replace-fail "python3" "${pythonEnv}/bin/python3" \
      --replace-fail "~/.config/mpv/scripts/interSubs.py" "$out/share/mpv/scripts/interSubs.py" \
      --replace-fail "pkill" "${killall}/bin/killall"

    substituteInPlace $out/share/mpv/scripts/interSubs.py \
      --replace-fail "pth = os.path.expanduser('~/.config/mpv/scripts/')" "pth = '$out/share/mpv/scripts/'"
    runHook postInstall
  '';

  passthru = {
    scriptName = "interSubs.lua";
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "Interactive subtitles for mpv";
    homepage = "https://github.com/oltodosel/interSubs";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
