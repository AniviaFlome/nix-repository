{
  lib,
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  gtk3,
  glib,
  gsettings-desktop-schemas,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dota2-rpc-client";
  version = "1.0.11";

  src = fetchzip {
    url = "https://github.com/andsfonseca/dota2-rpc-client/releases/download/v${finalAttrs.version}/dota2-rpc-client-linux.zip";
    hash = "sha256-fAURoNlRTB+s/q8kq6p3R4bySXaEj9G5Nu3vZwn/OZQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    gtk3
    glib
    gsettings-desktop-schemas
  ];

  installPhase = ''
    runHook preInstall

    # gsettings schemas needed by the GTK folder-picker (nativefiledialog)
    # used by `dota2-rpc-client -i` when Steam is not auto-detected.
    schemaPaths=""
    for pkg in ${gtk3} ${glib} ${gsettings-desktop-schemas}; do
      dir=$(echo "$pkg"/share/gsettings-schemas/*/glib-2.0/schemas)
      if [ -d "$dir" ]; then
        schemaPaths="''${schemaPaths:+$schemaPaths:}$dir"
      fi
    done
    [ -n "$schemaPaths" ] || (echo "no gsettings schemas found" >&2; exit 1)

    appDir=$out/share/dota2-rpc-client
    mkdir -p $appDir $out/bin
    cp $src/dota2-rpc-client $appDir/
    cp $src/libdiscord_game_sdk.so $appDir/
    cp $src/config.json $appDir/
    cp -r $src/lang $appDir/
    cp -r $src/templates $appDir/
    cp $src/dota2-rpc-client.service $appDir/
    chmod +x $appDir/dota2-rpc-client

    substitute ${./wrapper.sh} $out/bin/dota2-rpc-client \
      --replace-fail "@appDir@" "$appDir" \
      --replace-fail "@version@" "${finalAttrs.version}" \
      --replace-fail "@gsettingsSchemas@" "$schemaPaths"
    chmod +x $out/bin/dota2-rpc-client

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Show your Dota 2 match status on Discord via Rich Presence";
    homepage = "https://github.com/andsfonseca/dota2-rpc-client";
    changelog = "https://github.com/andsfonseca/dota2-rpc-client/releases/tag/v${finalAttrs.version}";
    longDescription = ''
      Displays live Dota 2 match information (hero, K/D/A, gold, items,
      buffs) as Discord Rich Presence using the Dota 2 game state
      integration API. Run `dota2-rpc-client -i` once to install the
      gamestate_integration_rpc.cfg into your Dota 2 cfg directory, then
      expose it as a systemd user service with the bundled
      dota2-rpc-client.service (see $out/share/dota2-rpc-client/).
    '';
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "dota2-rpc-client";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
})
