{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:
buildLua {
  pname = "mpv-file-browser";
  version = "0-unstable-2026-01-10";

  src = fetchFromGitHub {
    owner = "CogentRedTester";
    repo = "mpv-file-browser";
    rev = "c9f06f90f95444585ef02aa7a82ca10ff9e50db1";
    hash = "sha256-Rm34CT41wFZqaZ3I012/6HnjCGqyPWkcZyf/aQ8rb+A=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/mpv/scripts/file-browser
    cp -r main.lua modules $out/share/mpv/scripts/file-browser/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A simple no-dependency file browser for mpv player";
    homepage = "https://github.com/CogentRedTester/mpv-file-browser";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
