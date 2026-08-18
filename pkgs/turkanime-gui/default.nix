{
  lib,
  python3Packages,
  fetchPypi,
  mpv,
  makeWrapper,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "turkanime-gui";
  version = "10.1.0";
  pyproject = true;

  src = fetchPypi {
    pname = "turkanime_gui";
    inherit version;
    hash = "sha256-aROUR1/aVA4v2MvjJ9vLWqdZea7ENtDWn49YEx7oYzo=";
  };

  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages; [
    yt-dlp
    curl-cffi
    pycryptodome
    appdirs
    py7zr
    rich
    easygui
    questionary
    requests
    cloudscraper
    pillow
    pypresence
    toml
    selenium
    webdriver-manager
    beautifulsoup4
    customtkinter
    packaging
    rapidfuzz
  ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/turkanime-gui \
      --suffix PATH : ${lib.makeBinPath [ mpv ]}
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Türkanime video oynatıcı ve indirici (GUI)";
    homepage = "https://github.com/barkeser2002/turkanime-gui";
    license = lib.licenses.cc-by-nc-nd-40;
    maintainers = [ ];
    mainProgram = "turkanime-gui";
    platforms = lib.platforms.linux;
  };
}
