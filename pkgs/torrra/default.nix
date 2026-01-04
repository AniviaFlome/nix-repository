{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  zlib,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "torrra";
  version = "2.0.6";

  src = fetchurl {
    url = "https://github.com/stabldev/torrra/releases/download/v${finalAttrs.version}/torrra_v${finalAttrs.version}_linux_x86_64";
    hash = "sha256-nXIOy+nl90WCZ5TrsdMzlXU4LBYTe+Aq/r4BQftt/Rc=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ zlib ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/torrra

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A Python tool that lets you search and download torrents without leaving your CLI";
    homepage = "https://github.com/stabldev/torrra";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "torrra";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
