{
  lib,
  python3Packages,
  fetchPypi,
  mpv,
  aria2,
  geckodriver,
  makeWrapper,
  nix-update-script,
}:

let
  # curl-cffi 0.15.0's test suite fails on 4 SSL/cookie tests in the Nix
  # sandbox (different curl error message + cookie behaviour). Disable the
  # check phase so dependents can build; the package itself is unaffected.
  python3Packages' = python3Packages.overrideScope (
    _final: prev: {
      curl-cffi = prev.curl-cffi.overridePythonAttrs { doCheck = false; };
    }
  );
in
python3Packages'.buildPythonApplication rec {
  pname = "turkanime-cli";
  version = "10.0.3";
  pyproject = true;

  src = fetchPypi {
    pname = "turkanime_cli";
    inherit version;
    hash = "sha256-OJsibbuTrhMFEnkrKgKgksM+dPjvrxJvGYTOi8sw+4A=";
  };

  postPatch = ''
    substituteInPlace turkanime_api/bypass.py \
      --replace-fail 'impersonate="firefox"' 'impersonate="chrome110"'
  '';

  build-system = [ python3Packages.poetry-core ];

  nativeBuildInputs = [ makeWrapper ];

  dependencies = with python3Packages'; [
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
          python3Packages'.yt-dlp
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
