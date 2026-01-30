{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  fzf,
  rofi,
  nix-update-script,
}:

buildGoModule {
  pname = "anitr-cli";
  version = "unstable-2025-01-29";

  src = fetchFromGitHub {
    owner = "axrona";
    repo = "anitr-cli";
    rev = "main";
    hash = "sha256-QEuzHqfz35bEUxACpUQgU6cu+2NmLof6lNUJcTwatkk=";
  };

  vendorHash = "sha256-XGErf+LACVenbUfnvCPNfs3iCAK2Rzrtys5YKxrkkMc=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/anitr-cli \
      --suffix PATH : ${
        lib.makeBinPath [
          mpv
          fzf
          rofi
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Anime tracker and streamer CLI";
    homepage = "https://github.com/axrona/anitr-cli";
    license = licenses.mit; # Assumption, will verify
    mainProgram = "anitr-cli";
    platforms = platforms.linux;
  };
}
