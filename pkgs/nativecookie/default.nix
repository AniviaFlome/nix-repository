{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  electron,
  xdg-utils,
  makeWrapper,
  # Can be overridden to alter the display name in steam
  steamDisplayName ? "NativeCookie",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "nativecookie";
  version = "2.8";

  src = fetchzip {
    url = "https://github.com/Kesefon/NativeCookie/releases/download/v${finalAttrs.version}/nativecookie.tar.gz";
    hash = "sha256-Jx/eobxIOfPu+3/CdG+WdtCXBwRhfoFamhLjlY6wR/E=";
    stripRoot = false;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir -p $steamcompattool

    # Link all files except electron directory (which contains placeholders)
    # and compatibilitytool.vdf (which we need to modify)
    for f in $src/*; do
      name=$(basename "$f")
      if [[ "$name" != "electron" && "$name" != "compatibilitytool.vdf" ]]; then
        ln -s "$f" "$steamcompattool/$name"
      fi
    done

    # Copy compatibilitytool.vdf so we can modify it
    cp $src/compatibilitytool.vdf $steamcompattool/compatibilitytool.vdf

    # Set up electron symlinks - the binary expects electron at ./electron/electron or ./electron/cookie-electron
    mkdir -p $steamcompattool/electron
    ln -s ${electron}/bin/electron $steamcompattool/electron/electron
    ln -s ${electron}/bin/electron $steamcompattool/electron/cookie-electron

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail '"display_name" "NativeCookie"' '"display_name" "${steamDisplayName}"'

    # Wrap the binary to ensure xdg-utils is in PATH
    wrapProgram $steamcompattool/nativecookie \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  passthru.updateScript = writeScript "update-nativecookie" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    repo="https://api.github.com/repos/Kesefon/NativeCookie/releases"
    version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output | sed 's/^v//')"
    update-source-version nativecookie "$version"
  '';

  meta = {
    description = ''
      Run Cookie Clicker Steam edition with native Electron on Linux.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/Kesefon/NativeCookie";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
