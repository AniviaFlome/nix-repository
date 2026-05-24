{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation {
  pname = "adore";
  version = "latest";
  srcs = [
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16.onnx";
      hash = "sha256-eeAH7aVyHPpZaUXVhJMg4vrWf4WW+awx7QbMjj3a9X0=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_DML.onnx";
      hash = "sha256-18etrxUHlYNR2kCDT7SfixpJfaHMgGMsnM7E4ADAwQM=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_DML_onnxslim.onnx";
      hash = "sha256-dt/FSa6P+XEwyDnWmWGUGDcgZodfzkP3d7d61NU5INo=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_onnxslim.onnx";
      hash = "sha256-8+nbphKoO/u1eg+nqut+ER5GdTyrJ37tKpQjANXtFeA=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp32.onnx";
      hash = "sha256-UywbMHEcK7fqbd8SP9IZ34fKmBb7uN2qrVwfMR1bfEQ=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp32_DML.onnx";
      hash = "sha256-af9bJtm743JdP0EJiMfVRxmHd4fC2N+7zu2XRT3LwwM=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp32_DML_onnxslim.onnx";
      hash = "sha256-4d+sCk8P6xBli8EzvQMOoi/H/1pMEhn0seOG6TwnaNM=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp32_onnxslim.onnx";
      hash = "sha256-dW9C2sUMogw0d/1D0y2N0pXHRzztwSQpMKixUFTAQ1g=";
    })
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    for src in $srcs; do
      install -D -m644 $src $out/$(stripHash $src)
    done
    runHook postInstall
  '';

  meta = {
    description = "A collection of custom Super-Resolution models and restoration experiments.";
    homepage = "https://github.com/renarchi/Re-SISR";
    license = lib.licenses.cc-by-nc-sa-40;
    maintainers = [ ];
  };
}
