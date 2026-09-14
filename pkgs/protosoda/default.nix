{
  lib,
  stdenvNoCC,
  fetchzip,
  makeReleaseUpdater,
  steamDisplayName ? "ProtoSoda",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "protosoda";
  version = "11.0-3";

  src = fetchzip {
    url = "https://github.com/bottlesdevs/wine/releases/download/protosoda-${finalAttrs.version}/ProtoSoda-${finalAttrs.version}.tar.gz";
    hash = "sha256-jdJS1Z+GZMjeMfdjH5krp/Seiou9ePUmp4FLvHYY8rg=";
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
      --replace-fail "ProtoSoda-${finalAttrs.version}" "${steamDisplayName}"
  '';

  passthru.updateScript = makeReleaseUpdater {
    name = "protosoda";
    repo = "https://api.github.com/repos/bottlesdevs/wine/releases";
    versionFilter = "sed 's/^protosoda-//'";
    tagPrefix = "protosoda-";
  };

  meta = {
    description = ''
      Soda Wine runner in a Proton/UMU layout for Steam Play and umu-launcher.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/bottlesdevs/wine";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
