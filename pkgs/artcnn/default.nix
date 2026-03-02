{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "artcnn";
  version = "0-unstable-2025-02-14";

  src = fetchFromGitHub {
    owner = "Artoriuz";
    repo = "ArtCNN";
    rev = "5e868ea48bde5fc3686baf2008c5d172dd0225b1";
    hash = "sha256-DOJqyDwkxYbyfNlc++Or653Nt1UrA7EfA9nRrVcWRTA=";
  };

  dontBuild = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    install -D -m644 $src/GLSL/ArtCNN.glsl $out/share/mpv/shaders/ArtCNN.glsl

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
