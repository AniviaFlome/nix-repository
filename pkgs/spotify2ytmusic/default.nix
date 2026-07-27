{
  lib,
  python3,
  fetchFromGitHub,
  fetchpatch,
  nix-update-script,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "spotify2ytmusic";
  version = "0.9.32";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "linsomniac";
    repo = "spotify_to_ytmusic";
    rev = version;
    hash = "sha256-l784sTTBDFj+x/yEwz+HHdIRf5lARWHcif9qrNES4s0=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linsomniac/spotify_to_ytmusic/commit/d47bcc78bac2d4dc831d8719c90f190e4ffb8913.patch";
      hash = "sha256-DS/WlJLfTZmQO3azSUfyrSctNQFmBWembNPWVN5PrTw=";
    })
    (fetchpatch {
      url = "https://github.com/linsomniac/spotify_to_ytmusic/pull/184.patch";
      excludes = [ "settings.json" ];
      hash = "sha256-TUaefkIdxYDn0R0nTRI4oMraTj5kkmKjPanp2B+KTo4=";
    })
  ];

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  propagatedBuildInputs = [
    python3.pkgs.ytmusicapi
    python3.pkgs.tkinter
  ];

  pythonImportsCheck = [ "spotify2ytmusic" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Copy playlists and liked music from Spotify to YTMusic";
    homepage = "https://github.com/linsomniac/spotify_to_ytmusic";
    license = licenses.cc0;
    mainProgram = "s2yt_load_liked";
    platforms = platforms.linux;
  };
}
