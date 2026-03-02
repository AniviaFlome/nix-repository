{
  lib,
  stdenvNoCC,
  fetchzip,
  makeReleaseUpdater,
  # Can be overridden to alter the display name in steam
  # This could be useful if multiple versions should be installed together
  steamDisplayName ? "dwproton",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dwproton";
  version = "10.0-18";

  src = fetchzip {
    url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${finalAttrs.version}/dwproton-${finalAttrs.version}-x86_64.tar.xz";
    hash = "sha256-v87DiRf/NFMeDa0D9Td24zIZOvU5fIZ5JfNfLSAYGXc=";
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
      --replace-fail "dwproton-${finalAttrs.version}" "${steamDisplayName}"
  '';

  passthru.updateScript = makeReleaseUpdater {
    name = "dwproton";
    repo = "https://dawn.wine/api/v1/repos/dawn-winery/dwproton/releases";
    versionFilter = "sed 's/^dwproton-//'";
  };

  meta = {
    description = ''
      Proton builds with the latest Dawn Winery fixes for games like Genshin Impact, Zenless Zone Zero.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
