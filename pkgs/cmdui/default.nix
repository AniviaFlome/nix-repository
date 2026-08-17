{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (_finalAttrs: {
  pname = "cmdui";
  version = "0-unstable-2026-07-11";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "cmdui";
    rev = "2b2cd81bef14c016de2f57a5e0526df7df445721";
    hash = "sha256-9GtmIryBeSKP9MYc26vMHH5HEY6Wi+NVHyqMqoZelq4=";
  };

  vendorHash = "sha256-EuSeiiCjt2pOmKfHbZHIEX+mWgZtzFR29+1auhEvNOg=";

  env.CGO_ENABLED = 0;

  postInstall = ''
    mkdir -p $out/share/cmdui/examples
    cp examples/*.yaml $out/share/cmdui/examples/
    ln -s $out/share/cmdui/examples $out/examples
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Data-driven TUI command-line builder";
    homepage = "https://github.com/AniviaFlome/cmdui";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "cmdui";
    platforms = platforms.linux;
  };
})
