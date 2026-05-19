{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "artcnn";
  version = "0-unstable-2026-05-18";

  src = fetchFromGitHub {
    owner = "Artoriuz";
    repo = "ArtCNN";
    rev = "b2fb535f3446060f9cb1782937f46385ea6cacc5";
    hash = "sha256-SZjZbqap+R1Xx44tIrGtQhIKqrET+/dl3iCKDMOv2tQ=";
  };

  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

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
