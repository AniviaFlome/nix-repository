{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "caveman-skills";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GfC8e+EGL7kotZQfZ9kD7ZEWJfhmXujHOHpMxeU3bEo=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/skills
    for skill in $src/skills/*/; do
      if [[ -f "$skill/SKILL.md" ]]; then
        cp -R "$skill" $out/share/skills/
      fi
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Token-efficient AI agent skills (caveman-commit, caveman-help and friends)";
    homepage = "https://github.com/JuliusBrussee/caveman";
    changelog = "https://github.com/JuliusBrussee/caveman/releases/tag/v${finalAttrs.version}";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
  };
})
