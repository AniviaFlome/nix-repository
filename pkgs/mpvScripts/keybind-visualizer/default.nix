{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "keybind-visualizer";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "d0188f3d1298744f4f9cda15a00f97b8513b8702";
    hash = "sha256-cnv1wWYx5ZcYcKinwa4FWcReRjvnMJshSsMZwIsL/E0=";
  };

  installPhase = ''
    runHook preInstall
    install -D -m644 portable_config/scripts/keybind-visualizer.lua $out/share/mpv/scripts/keybind-visualizer.lua
    install -D -m644 portable_config/script-opts/keybind-visualizer-layouts.json $out/share/keybind-visualizer-layouts.json
    substituteInPlace $out/share/mpv/scripts/keybind-visualizer.lua \
      --replace-fail '"script-opts/keybind-visualizer-layouts.json"' "'$out/share/keybind-visualizer-layouts.json'"
    runHook postInstall
  '';

  passthru = {
    updatePr = true;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Interactive on-screen keyboard for mpv that shows the bindings of the hovered key";
    homepage = "https://github.com/v-amorim/mpv";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
