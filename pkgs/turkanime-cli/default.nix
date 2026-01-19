{
  lib,
  python3Packages,
  fetchPypi,
  mpv,
  makeWrapper,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "turkanime-cli";
  version = "9.0.2";
  pyproject = true;

  src = fetchPypi {
    pname = "turkanime_cli";
    inherit version;
    hash = "sha256-/nLqbp6D+m7URKerNJb4f0OU0o41slMzpcJPgJQhqb4=";
  };

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
      --prefix PATH : ${lib.makeBinPath [ mpv ]}
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
