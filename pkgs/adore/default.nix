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
      sha256 = "79e007eda5721cfa596945d5849320e2fad67f8596f9ac31ed06cc8e3ddaf57d";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_DML.onnx";
      sha256 = "d7c7adaf1507958351da40834fb49f8b1a497da1cc80632c9ccec4e000c0c103";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_DML_onnxslim.onnx";
      sha256 = "76dfc549ae8ff97130c839d699619418372066875fce43f777b77ad4d53920da";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_DML_op23.onnx";
      sha256 = "d7c7adaf1507958351da40834fb49f8b1a497da1cc80632c9ccec4e000c0c103";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_DML_op23_onnxslim.onnx";
      sha256 = "76dfc549ae8ff97130c839d699619418372066875fce43f777b77ad4d53920da";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_onnxslim.onnx";
      sha256 = "f3e9dba612a83bfbb57a0fa7aaeb7e111e46753cab277eed2a942300d5ed15e0";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_op23.onnx";
      sha256 = "ae76ac6efc513bd131f730754455994fbb91ddc1ef9d3bc31078bcd57bdf4181";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Adore/2x_Adore_renarchi_fp16_op23_onnxslim.onnx";
      sha256 = "6c3a6fdc4db49de207b34a69dd90c0792698eeb9c688070d94e4706ce58519d5";
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
