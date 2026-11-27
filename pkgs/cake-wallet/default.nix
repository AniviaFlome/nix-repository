{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gtk3,
  glib,
  cairo,
  pango,
  gdk-pixbuf,
  at-spi2-atk,
  libxkbcommon,
  libdrm,
  mesa,
  alsa-lib,
  nss,
  nspr,
  expat,
  cups,
  makeDesktopItem,
  copyDesktopItems,
  libgcrypt,
  lz4,
  libgpg-error,
  makeWrapper,
  writeShellScript,
  curl,
  jq,
  gnused,
}:

stdenv.mkDerivation {
  pname = "cake-wallet";
  version = "6.4.4";

  src = fetchurl {
    url = "https://github.com/cake-tech/cake_wallet/releases/download/v6.4.4/Cake_Wallet_v6.4.4_Linux.tar.xz";
    hash = "sha256-wkMQuPChEVgOWfOLSM/UD2bG5DU9dim+44sEnla5ECU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;
  preferLocalBuild = true;

  buildInputs = [
    gtk3
    glib
    cairo
    pango
    gdk-pixbuf
    at-spi2-atk
    libxkbcommon
    libdrm
    mesa
    alsa-lib
    nss
    nspr
    expat
    cups
    libgcrypt
    lz4
    libgpg-error
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/cake-wallet

    cp -r * $out/lib/cake-wallet/

    ln -s $out/lib/cake-wallet/cake_wallet $out/bin/cake-wallet

    wrapProgram $out/bin/cake-wallet \
      --set GDK_BACKEND x11 # Does not work with wayland

    runHook postInstall
  '';

  # Upstream frequently ships mobile-only releases without a Linux tarball,
  # or re-attaches an older Linux build (e.g. Cake_Wallet_v6.4.4_Linux.tar.xz
  # under tag v6.5.4). Scan releases for the newest Linux tarball asset and
  # track its actual version and download URL.
  passthru.updateScript = writeShellScript "update-cake-wallet" ''
    set -euo pipefail

    auth_args=()
    token="''${GITHUB_TOKEN:-''${GH_TOKEN:-}}"
    if [ -n "$token" ]; then
      auth_args=(-H "Authorization: Bearer $token")
    fi

    match=$(
      ${lib.getExe curl} -fsSL "''${auth_args[@]}" \
        "https://api.github.com/repos/cake-tech/cake_wallet/releases?per_page=30" \
      | ${lib.getExe jq} -r '
          [ .[]
            | select((.draft | not) and (.prerelease | not))
            | .assets[]
            | select(.name | test("^Cake_Wallet_v[0-9.]+_Linux\\.tar\\.xz$"))
            | {
                version: (.name | capture("^Cake_Wallet_v(?<v>[0-9.]+)_Linux\\.tar\\.xz$").v),
                url: .browser_download_url
              }
          ][0] // empty
          | "\(.version)\t\(.url)"
        '
    )

    if [ -z "$match" ]; then
      echo "No Linux tarball asset found in recent cake_wallet releases" >&2
      exit 1
    fi

    IFS=$'\t' read -r new_version new_url <<<"$match"
    old_version="''${UPDATE_NIX_OLD_VERSION:-}"

    if [ "$new_version" = "$old_version" ]; then
      echo "cake-wallet is already at the latest Linux version ($old_version)"
      exit 0
    fi

    raw_hash=$(nix-prefetch-url --type sha256 "$new_url")
    sri_hash=$(nix-hash --to-sri --type sha256 "$raw_hash")

    file="pkgs/cake-wallet/default.nix"
    ${lib.getExe gnused} -i \
      -e "s|version = \"[^\"]*\";|version = \"$new_version\";|" \
      -e "s|url = \"[^\"]*\";|url = \"$new_url\";|" \
      -e "s|hash = \"[^\"]*\";|hash = \"$sri_hash\";|" \
      "$file"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "cake-wallet";
      desktopName = "Cake Wallet";
      exec = "cake-wallet";
      icon = "cake-wallet";
      comment = "A non-custodial multi-currency wallet";
      categories = [
        "Office"
        "Finance"
      ];
    })
  ];

  meta = with lib; {
    description = "A non-custodial multi-currency wallet";
    homepage = "https://cakewallet.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "cake-wallet";
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
