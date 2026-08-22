{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (_finalAttrs: {
  pname = "cmdui";
  version = "0-unstable-2026-08-22";

  src = fetchFromGitHub {
    owner = "AniviaFlome";
    repo = "cmdui";
    rev = "a21d2ab8c77c80459c918e26f783426e7a8f70c8";
    hash = "sha256-js2kOZ1AD4nK6QBKGpF0fnovNwKowbQqzET2GguM/1Y=";
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
