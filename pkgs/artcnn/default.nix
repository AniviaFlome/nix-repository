{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "artcnn";
  version = "0-unstable-2026-10-20";

  src = fetchFromGitHub {
    owner = "Artoriuz";
    repo = "ArtCNN";
    rev = "e753502f647afdd4e80c2d7aba88a7c289ec8335";
    hash = "sha256-mZMzqTNNqaN8v1Ae9C6mvS6v4c374A0WaV93NQwg9Ng=";
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
