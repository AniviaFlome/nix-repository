{
  lib,
  buildLua,
  fetchFromGitHub,
  nix-update-script,
}:

buildLua {
  pname = "keybind-visualizer";
  version = "0-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "v-amorim";
    repo = "mpv";
    rev = "1d78c2f42ae0a4db021ce27f843d0e2dc1f92dd9";
    hash = "sha256-dRhL2BeNOeihgmpgN5kTtEr9JPDU66JH/mrQauYzV/0=";
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
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Interactive on-screen keyboard for mpv that shows the bindings of the hovered key";
    homepage = "https://github.com/v-amorim/mpv";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
