{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt6,
  makeWrapper,
  testers,
  nix-update-script,
  ffmpeg,
  gpu-screen-recorder,
  cloudflared,
  wl-clipboard,
  xclip,
  xsel,
  wmctrl,
  xdotool,
  xprop,
  wf-recorder,
  xdg-utils,
  alsa-utils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vice-clipper";
  version = "2.10.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "eklonofficial";
    repo = "Vice";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I6OQLNqKIfYeWAlBTnCumwKKcJS+4kb3cCPuluPXNSg=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    evdev
    aiohttp
    click
    psutil
    pywebview
    tomli-w
    pyqt6
    pyqt6-webengine
    qtpy
  ];

  nativeBuildInputs = [
    makeWrapper
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtwayland
  ];

  # buildPythonApplication already wraps via makeWrapper; merge the Qt
  # wrapper args into that single wrapper instead of double-wrapping.
  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${qtWrapperArgs[@]}"
      --prefix PATH : "${
        lib.makeBinPath [
          ffmpeg
          gpu-screen-recorder
          cloudflared
          wl-clipboard
          xclip
          xsel
          wmctrl
          xdotool
          xprop
          wf-recorder
          xdg-utils
          alsa-utils
        ]
      }"
    )
  '';

  postInstall = ''
    install -Dm644 vice.desktop $out/share/applications/vice.desktop
    substituteInPlace $out/share/applications/vice.desktop \
      --replace-fail 'Exec=vice-app' "Exec=$out/bin/vice-app"

    install -Dm644 assets/vice.svg $out/share/icons/hicolor/scalable/apps/vice.svg

    install -Dm644 packaging/vice.rules $out/lib/udev/rules.d/70-vice-input.rules

    install -Dm644 packaging/vice.service $out/lib/systemd/user/vice.service
    substituteInPlace $out/lib/systemd/user/vice.service \
      --replace-fail '/usr/bin/vice' "$out/bin/vice"
  '';

  # Upstream tests need ffmpeg, a display server and a GPU; the Arch
  # package only runs `python -m compileall`.
  doCheck = false;

  pythonImportsCheck = [ "vice" ];

  passthru = {
    updateScript = nix-update-script { };
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  meta = {
    description = "Medal.tv-style game clip recorder for Linux: instant replay, session recording, and one-click sharing";
    homepage = "https://github.com/eklonofficial/Vice";
    changelog = "https://github.com/eklonofficial/Vice/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "vice";
    platforms = [ "x86_64-linux" ];
  };
})
