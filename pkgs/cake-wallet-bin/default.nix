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
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "cake-wallet-bin";
  version = "6.1.2";

  src = fetchurl {
    url = "https://github.com/cake-tech/cake_wallet/releases/download/v${version}/Cake_Wallet_v${version}_Linux.tar.xz";
    sha256 = "sha256-awZut6smNYb+HMPYNsRTKlW09PnqGFWCklQddcSXH7A=";
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

  passthru.updateScript = nix-update-script { };

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
  };
}
