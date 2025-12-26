{
  lib,
  buildLua,
  fetchFromGitHub,
  whisper-cpp,
  ffmpeg,
}:

buildLua {
  pname = "whisper-subs";
  version = "unstable-2025-02-09";

  src = fetchFromGitHub {
    owner = "GhostNaN";
    repo = "whisper-subs";
    rev = "721f97adb70a04bb62fd6c134b3b0b6441e6cf75";
    hash = "sha256-bLTVyNlhYO7WXppXEIfFwbIgJRCRLH5CGNVUVtn6Pyo=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 whispersubs.lua $out/share/mpv/scripts/whispersubs.lua

    substituteInPlace $out/share/mpv/scripts/whispersubs.lua \
      --replace-fail "whisper-cli" "${whisper-cpp}/bin/whisper-cpp" \
      --replace-fail 'ffmpeg' "${ffmpeg}/bin/ffmpeg"
    runHook postInstall
  '';

  passthru.scriptName = "whispersubs.lua";

  meta = {
    description = "WhisperSubs is a mpv lua script to generate subtitles at runtime with whisper.cpp on Linux";
    homepage = "https://github.com/GhostNaN/whisper-subs";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
