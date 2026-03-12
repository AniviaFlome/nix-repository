{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "artcnn";
  version = "1.6.1-unstable-2026-03-11";

  src = fetchFromGitHub {
    owner = "Artoriuz";
    repo = "ArtCNN";
    rev = "cc2fa898b4b2eb211431c0d00f6f0db0ade37579";
    hash = "sha256-OPGOfksX7xjYGgZHoTj6y1XHPD4rpnEnglagewoy/ZY=";
  };

  dontBuild = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    install -D -m644 $src/GLSL/*.glsl -t $out/

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "ArtCNN shaders for MPV";
    homepage = "https://github.com/Artoriuz/ArtCNN";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
