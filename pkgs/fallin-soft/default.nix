{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "re-sisr-soft";
  version = "latest";

  src = fetchurl {
    url = "https://github.com/renarchi/Re-SISR/releases/download/Fallin/2x_Fallin_soft_renarchi_fp16.onnx";
    hash = "sha256-F6TAxq9aGHOJ9Sqb0CZVOogZ8Ui3DeoaJC0VF6NS3+w=";
  };

  dontUnpack = true;
  dontBuild = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    install -D -m644 $src $out/share/mpv/shaders/Fallin_Soft.onnx

    runHook postInstall
  '';

  meta = {
    description = "Pre-trained models for Re-SISR (soft)";
    homepage = "https://github.com/renarchi/Re-SISR";
    license = lib.licenses.cc-by-sa-40;
    maintainers = [ ];
  };
}
