{
  lib,
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "fallin";
  version = "latest";

  srcs = [
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Fallin/2x_Fallin_soft_renarchi_fp16.onnx";
      hash = "sha256-F6TAxq9aGHOJ9Sqb0CZVOogZ8Ui3DeoaJC0VF6NS3+w=";
    })
    (fetchurl {
      url = "https://github.com/renarchi/Re-SISR/releases/download/Fallin/2x_Fallin_strong_renarchi_fp16.onnx";
      hash = "sha256-89Y24piiL9VK1mVx509ska/GzHkpeZ0iTcbruGTBKN8=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A collection of custom Super-Resolution models and restoration experiments.";
    homepage = "https://github.com/renarchi/Re-SISR";
    license = lib.licenses.cc-by-sa-40;
    maintainers = [ ];
  };
}
