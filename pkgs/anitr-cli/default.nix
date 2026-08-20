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
    hash = "sha256-KBFWSNu0KgruFgZP3Qdv1Fj3QYJqg/75ruj+T+KIulg=";
  };

  vendorHash = "sha256-XGErf+LACVenbUfnvCPNfs3iCAK2Rzrtys5YKxrkkMc=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/axrona/anitr-cli/internal/update.version=${finalAttrs.version}"
  ];

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
    license = licenses.mit;
    mainProgram = "anitr-cli";
    platforms = platforms.linux;
  };
})
