{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "keybind-visualizer";
  version = "0-unstable-2026-09-21";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "f5fbb67aac64b8367250c358a00444c7197fa38b";
    hash = "sha256-edPmI9SzAwKLQk4LjihZVZ9qx9V3FVq6F906Z7OvJE4=";
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
