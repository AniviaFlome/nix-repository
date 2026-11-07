{
  lib,
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  openssl,
  krb5,
  icu,
  zlib,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "osu-beatmap-manager";
  version = "0.1.0";

  src = fetchzip {
    url = "https://github.com/AniviaFlome/osu-beatmap-manager/releases/download/v${finalAttrs.version}/obm-v${finalAttrs.version}-linux-x64.tar.gz";
    hash = "sha256-SnwBAr9oirjAIMnzmLiGinNFLBjlcEzGlKnW3fQBxJE=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    openssl
    krb5
    icu
    zlib
  ];

  installPhase = ''
    runHook preInstall

    appDir=$out/share/osu-beatmap-manager
    mkdir -p $appDir $out/bin
    cp $src/obm $src/librealm-wrappers.so $appDir/
    chmod +x $appDir/obm

    # The self-contained apphost links ICU/OpenSSL/Kerberos by unversioned
    # linker names that only exist in dev outputs, so autoPatchelf drops
    # them; the .NET host dlopens the versioned libs at runtime instead.
    # Expose them via LD_LIBRARY_PATH. $appDir stays the app directory
    # (wrapper execs the real binary), so librealm-wrappers.so next to
    # it is still found.
    makeWrapper $appDir/obm $out/bin/obm \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          openssl
          krb5
          icu
          zlib
        ]
      }"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "osu! Beatmap Manager";
    homepage = "https://github.com/AniviaFlome/osu-beatmap-manager";
    changelog = "https://github.com/AniviaFlome/osu-beatmap-manager/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "obm";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
