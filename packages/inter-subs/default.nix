{ lib, stdenv, fetchFromGitHub, python3, lua, socat, killall, xdotool, makeWrapper }:

let
  pythonEnv = python3.withPackages (ps: with ps; [
    pyqt5
    numpy
    beautifulsoup4
    requests
    lxml
    httpx
  ]);
in
stdenv.mkDerivation rec {
  pname = "inter-subs";
  version = "0-unstable-2025-03-18";

  src = fetchFromGitHub {
    owner = "oltodosel";
    repo = "interSubs";
    rev = "a4113586db8f60f1c533f717c1c1a928f3723049";
    sha256 = "0xp1jz85nff99fnbqn2p1vigrr1z2msd7y4bj70fwa3kp88iyzdp";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp interSubs.lua interSubs.py interSubs_config.py $out/share/mpv/scripts/

    substituteInPlace $out/share/mpv/scripts/interSubs.lua \
      --replace "python3" "${pythonEnv}/bin/python3" \
      --replace "~/.config/mpv/scripts/interSubs.py" "$out/share/mpv/scripts/interSubs.py" \
      --replace "pkill" "${killall}/bin/pkill"
  '';

  meta = with lib; {
    description = "Interactive subtitles for mpv";
    homepage = "https://github.com/oltodosel/interSubs";
    license = licenses.mit;
    maintainers = with maintainers; [ AniviaFlome ];
  };
}
