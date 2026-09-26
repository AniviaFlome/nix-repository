{
  lib,
  python3Packages,
  fetchPypi,
  mpv,
  makeWrapper,
  nix-update-script,
}:

let
  # curl-cffi 0.15.0's test suite fails on 4 SSL/cookie tests in the Nix
  # sandbox. Disable the check phase so dependents can build.
  python3Packages' = python3Packages.overrideScope (
    _final: prev: {
      curl-cffi = prev.curl-cffi.overridePythonAttrs { doCheck = false; };
    }
  );
in
python3Packages'.buildPythonApplication rec {
  pname = "turkanime-gui";
  version = "10.2.0";
  pyproject = true;

  src = fetchPypi {
    pname = "turkanime_gui";
    inherit version;
    hash = "sha256-fGMJjk+oceCVP2g5VnMvlI3pJX1/t5L+N8cYnO/V2RM=";
  };

  build-system = [ python3Packages.poetry-core ];

  dependencies = with python3Packages'; [
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
