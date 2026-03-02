{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
}:

stdenvNoCC.mkDerivation rec {
  pname = "anime4k";
  version = "4.0.1";

  src = fetchzip {
    url = "https://github.com/bloc97/Anime4K/releases/download/v${version}/Anime4K_v4.0.zip";
    hash = "sha256-9B6U+KEVlhUIIOrDauIN3aVUjZ/gQHjFArS4uf/BpaM=";
    stripRoot = false;
  };

  dontBuild = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall
    
    install -D -m644 $src/GLSL/Anime4K_*.glsl $out/share/mpv/shaders/Anime4K

    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "A High-Quality Real Time Upscaler for Anime Video";
    homepage = "https://github.com/bloc97/Anime4K";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
