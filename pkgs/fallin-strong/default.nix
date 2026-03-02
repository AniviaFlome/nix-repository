{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "re-sisr-strong";
  version = "latest";

  src = fetchurl {
    url = "https://github.com/renarchi/Re-SISR/releases/download/Fallin/2x_Fallin_strong_renarchi_fp16.onnx";
    hash = "sha256-89Y24piiL9VK1mVx509ska/GzHkpeZ0iTcbruGTBKN8=";
  };

  dontUnpack = true;
  dontBuild = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    install -D -m644 $src $out/share/mpv/shaders/Fallin_Strong.onnx

    runHook postInstall
  '';

  meta = {
    description = "Pre-trained models for Re-SISR (strong)";
    homepage = "https://github.com/renarchi/Re-SISR";
    license = lib.licenses.cc-by-sa-40;
    maintainers = [ ];
  };
}
