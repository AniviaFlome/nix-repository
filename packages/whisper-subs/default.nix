{ lib, stdenv, fetchFromGitHub, whisper-cpp, ffmpeg, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "whisper-subs";
  version = "0-unstable-2025-02-09";

  src = fetchFromGitHub {
    owner = "GhostNaN";
    repo = "whisper-subs";
    rev = "721f97adb70a04bb62fd6c134b3b0b6441e6cf75";
    sha256 = "0aizzbcmcm6m3117wb4i20jj1cn1qn3i0mwsbvbfwq31v74dbd3c";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp whispersubs.lua $out/share/mpv/scripts/

    substituteInPlace $out/share/mpv/scripts/whispersubs.lua \
      --replace "whisper-cli" "${whisper-cpp}/bin/whisper-cpp" \
      --replace "ffmpeg" "${ffmpeg}/bin/ffmpeg"
  '';

  meta = with lib; {
    description = "WhisperSubs is a mpv lua script to generate subtitles at runtime with whisper.cpp on Linux";
    homepage = "https://github.com/GhostNaN/whisper-subs";
    license = licenses.mit;
    maintainers = with maintainers; [ AniviaFlome ];
  };
}
