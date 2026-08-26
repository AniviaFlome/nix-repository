{
  lib,
  buildLua,
  fetchFromGitHub,
  python3,
  procps,
  qt5,
  makeWrapper,
  nix-update-script,
}:
let
  pythonEnv = python3.withPackages (ps: [
    ps.beautifulsoup4
    ps.httpx
    ps.lxml
    ps.numpy
    ps.pyqt5
    ps.requests
    ps.six
  ]);
in
buildLua {
  pname = "interSubs";
  version = "0-unstable-2025-03-18";

  src = fetchFromGitHub {
    owner = "oltodosel";
    repo = "interSubs";
    rev = "a4113586db8f60f1c533f717c1c1a928f3723049";
    hash = "sha256-t30fEbpzKO7AkYv403QVP+T84g5XWLysS8k5W9CX4XY=";
  };

  nativeBuildInputs = [
    makeWrapper
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ qt5.qtwayland ];

  postPatch = ''
    substituteInPlace interSubs.lua \
      --replace-fail "start_command = 'python3 \"%s\" \"%s\" \"%s\"'" \
        "start_command = mp.get_script_directory() .. '/interSubs-python \"%s\" \"%s\" \"%s\"'" \
      --replace-fail "pyname = '~/.config/mpv/scripts/interSubs.py'" \
        "pyname = mp.get_script_directory() .. '/interSubs.py'" \
      --replace-fail "pkill" "${lib.getExe' procps "pkill"}"

    substituteInPlace interSubs.py \
      --replace-fail "pth = os.path.expanduser('~/.config/mpv/scripts/')" \
        "pth = os.path.join(os.environ.get('XDG_CACHE_HOME', os.path.expanduser('~/.cache')), 'interSubs'); os.makedirs(pth, exist_ok=True)"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 interSubs.lua interSubs.py interSubs_config.py \
      -t $out/share/mpv/scripts

    makeWrapper ${pythonEnv}/bin/python3 \
      $out/share/mpv/scripts/interSubs-python
    wrapQtApp $out/share/mpv/scripts/interSubs-python

    PYTHONWARNINGS=ignore::SyntaxWarning \
      ${pythonEnv}/bin/python3 -m compileall -q \
      $out/share/mpv/scripts

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Interactive subtitles for mpv";
    homepage = "https://github.com/oltodosel/interSubs";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
