{
  lib,
  stdenvNoCC,
  fetchzip,
  makeReleaseUpdater,
  # Can be overridden to alter the display name in steam
  steamDisplayName ? "proton-cachyos",
  # x86_64 microarchitecture level: "" (baseline), "_v2", "_v3", or "_v4"
  # Most modern CPUs support v3 (Haswell+), but v2 is safer for older hardware
  marchLevel ? "_v3",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos";
  version = "10.0-20260207";

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64${marchLevel}.tar.xz";
    hash = "sha256-LWiW601Dy5BMDQqjU+FnEl70a+9SoVjsJDWcCEUNij8=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  preferLocalBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "proton-cachyos-${finalAttrs.version}" "${steamDisplayName}"
  '';

  passthru.updateScript = makeReleaseUpdater {
    name = "proton-cachyos";
    repo = "https://api.github.com/repos/CachyOS/proton-cachyos/releases";
    versionFilter = "sed 's/^cachyos-//' | sed 's/-slr$//'";
  };

  meta = {
    description = ''
      CachyOS optimized Proton with x86_64${marchLevel} optimizations, DXVK-Sarek, FSR4, NTSync support.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
