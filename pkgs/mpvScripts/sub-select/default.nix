{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "sub-select";
  version = "0-unstable-2025-04-04";

  src = fetchFromGitHub {
    owner = "CogentRedTester";
    repo = "mpv-sub-select";
    rev = "26d24a0fd1d69988eaedda6056a2c87d0a55b6cb";
    hash = "sha256-+eVga4b7KIBnfrtmlgq/0HNjQVS3SK6YWVXCPvOeOOc=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts $out/share/mpv/script-opts
    install -m644 sub-select.lua $out/share/mpv/scripts/sub-select.lua
    install -m644 sub-select.json $out/share/mpv/script-opts/sub-select.json

    substituteInPlace $out/share/mpv/scripts/sub-select.lua \
      --replace-fail '~~/script-opts' "$out/share/mpv/script-opts"
    runHook postInstall
  '';

  passthru = {
    scriptName = "sub-select.lua";
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Advanced conditional subtitle track selector for mpv player";
    homepage = "https://github.com/CogentRedTester/mpv-sub-select";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
