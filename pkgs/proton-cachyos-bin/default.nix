{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  # Can be overridden to alter the display name in steam
  steamDisplayName ? "proton-cachyos",
  # x86_64 microarchitecture level: "" (baseline), "_v2", "_v3", or "_v4"
  # Most modern CPUs support v3 (Haswell+), but v2 is safer for older hardware
  marchLevel ? "_v3",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos-bin";
  version = "10.0-20260102";

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64${marchLevel}.tar.xz";
    hash = "sha256-vHwYpLMYQOLQY+hpXsAd7wIlApubp8WGKOv64cZOjpI=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
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

  passthru.updateScript = writeScript "update-proton-cachyos" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    repo="https://api.github.com/repos/CachyOS/proton-cachyos/releases"
    version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output | sed 's/^cachyos-//' | sed 's/-slr$//')"
    update-source-version proton-cachyos-bin "$version"
  '';

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
