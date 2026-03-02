{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  soft = fetchurl {
    url = "https://github.com/renarchi/Re-SISR/releases/download/Fallin/2x_Fallin_soft_renarchi_fp16.onnx";
    hash = "sha256-F6TAxq9aGHOJ9Sqb0CZVOogZ8Ui3DeoaJC0VF6NS3+w=";
  };

  strong = fetchurl {
    url = "https://github.com/renarchi/Re-SISR/releases/download/Fallin/2x_Fallin_strong_renarchi_fp16.onnx";
    hash = "sha256-89Y24piiL9VK1mVx509ska/GzHkpeZ0iTcbruGTBKN8=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "fallin";
  version = "latest";

  dontUnpack = true;
  dontBuild = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  installPhase = ''
    runHook preInstall

    install -D -m644 ${soft} $out/Fallin_Soft.onnx
    install -D -m644 ${strong} $out/Fallin_Strong.onnx

    runHook postInstall
  '';

  meta = {
    description = "A collection of custom Super-Resolution models and restoration experiments.";
    homepage = "https://github.com/renarchi/Re-SISR";
    license = lib.licenses.cc-by-sa-40;
    maintainers = [ ];
  };
}
