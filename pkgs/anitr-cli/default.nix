{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "anitr-cli";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "axrona";
    repo = "anitr-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QEuzHqfz35bEUxACpUQgU6cu+2NmLof6lNUJcTwatkk=";
  };

  vendorHash = "sha256-XGErf+LACVenbUfnvCPNfs3iCAK2Rzrtys5YKxrkkMc=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/anitr-cli \
      --suffix PATH : ${
        lib.makeBinPath [
          mpv
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
})
