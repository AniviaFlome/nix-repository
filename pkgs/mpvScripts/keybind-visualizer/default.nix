{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "keybind-visualizer";
  version = "0-unstable-2026-09-05";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "80854b78d10a535338a4d0c5a8df2731afef5c30";
    hash = "sha256-M8kBOIbD+Epl/TG6wVEvU5x+IEbyAPXq9tbiR8q6azo=";
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
