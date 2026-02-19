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
}:

stdenv.mkDerivation rec {
  pname = "cake-wallet-bin";
  version = "5.8.0";

  src = fetchurl {
    url = "https://github.com/cake-tech/cake_wallet/releases/download/v${version}/Cake_Wallet_v${version}_Linux.tar.xz";
    sha256 = "0349k1lfivl966cpzzsd3iy49yqlb54h3lkj400rzsnd0yag915v";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

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
      --set GDK_BACKEND x11

    # Install icon (assuming path based on inspection)
    # mkdir -p $out/share/icons/hicolor/512x512/apps
    # cp -r data/flutter_assets/assets/images/app_logo.png $out/share/icons/hicolor/512x512/apps/cake-wallet.png

    runHook postInstall
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
  };
}
