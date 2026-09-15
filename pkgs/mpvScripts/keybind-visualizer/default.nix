{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "keybind-visualizer";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "a6f3677037bcf6c28093926d3373915a2b4242ec";
    hash = "sha256-wEjrpN5KLVpnr4d3HmF2SAo8Kd4RENu21sDrV9heVgo=";
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
