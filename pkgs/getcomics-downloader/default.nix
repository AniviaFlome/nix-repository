{
  lib,
  python3,
  fetchFromGitHub,
  makeWrapper,
  aria2,
  nix-update-script,
}:

let
  pythonEnv = python3.withPackages (ps: [
    ps.beautifulsoup4
    ps.requests
    ps.rich
  ]);
in
python3.pkgs.buildPythonPackage rec {
  pname = "getcomics-downloader";
  version = "1.1";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "UlucKaymak";
    repo = "getcomics-downloader";
    rev = "v${version}";
    hash = "sha256-dSq1BsImzwyOUqa8fB9V5MPsyymWnodZGtHcB9Glxuk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    pkgDir=$out/lib/getcomics-downloader
    mkdir -p "$pkgDir"

    cp main.py getinfo.py download.py menu.py "$pkgDir/"

    makeWrapper ${pythonEnv}/bin/python $out/bin/getcomics-downloader \
      --add-flags "$pkgDir/main.py" \
      --suffix PATH : "${lib.makeBinPath [ aria2 ]}"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A TUI-based CLI tool to search for and download comics from getcomics.info";
    homepage = "https://github.com/UlucKaymak/getcomics-downloader";
    license = licenses.unfree; # No license file in upstream repository
    mainProgram = "getcomics-downloader";
    platforms = platforms.linux;
  };
}
