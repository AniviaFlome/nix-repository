{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "artcnn";
  version = "1.6.2-unstable-2026-07-23";

  src = fetchFromGitHub {
    owner = "Artoriuz";
    repo = "ArtCNN";
    rev = "a91902eeb2f8dc37bdd42892dc502211c6de5525";
    hash = "sha256-8mErPIewEInu6A4tqkFJetwgP7LEgWwJqiJI51tmjc0=";
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
