{
  lib,
  python3,
  fetchFromGitHub,
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
