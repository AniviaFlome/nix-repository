{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "artcnn";
  version = "1.6.2-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "Artoriuz";
    repo = "ArtCNN";
    rev = "861daef354c4e3e3dc111b0a5a17e085ad84b8e6";
    hash = "sha256-ZCrlQLuEPU07EkWuCh2KkkjV7A5odVaA9+8+V+V0IgQ=";
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
