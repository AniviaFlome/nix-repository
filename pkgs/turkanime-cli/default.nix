{
  lib,
  python3Packages,
  fetchPypi,
  mpv,
  aria2,
  geckodriver,
  yt-dlp,
  makeWrapper,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "turkanime-cli";
  version = "9.2.1";
  pyproject = true;

  src = fetchPypi {
    pname = "turkanime_cli";
    inherit version;
    hash = "sha256-y6rhifoc+tH4lKIpLyvg96cyN9CB2faDF2phegRnoCM=";
  };

  postPatch = ''
    substituteInPlace turkanime_api/bypass.py \
      --replace-fail 'impersonate="firefox"' 'impersonate="chrome110"'
  '';

  build-system = [ python3Packages.poetry-core ];

  nativeBuildInputs = [ makeWrapper ];

  dependencies = with python3Packages; [
    yt-dlp
    curl-cffi
    pycryptodome
    appdirs
    questionary
    py7zr
    rich
    easygui
  ];

  postInstall = ''
    wrapProgram $out/bin/turkanime \
      --suffix PATH : ${
        lib.makeBinPath [
          mpv
          aria2
          geckodriver
          yt-dlp
        ]
      }
  '';

  # No tests available
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Türk Anime python kütüphanesi ve tarayıcısı";
    homepage = "https://github.com/KebabLord/turkanime-indirici";
    license = lib.licenses.cc-by-nc-nd-40;
    maintainers = [ ];
    mainProgram = "turkanime";
    platforms = lib.platforms.linux;
  };
}
