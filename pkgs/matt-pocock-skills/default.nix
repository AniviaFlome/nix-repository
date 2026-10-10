{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "matt-pocock-skills";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/mAmj7QFdyOWhLmy3Rt2/Hfsh5qwirTRax7hmQffFdo=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/skills
    for group in engineering productivity; do
      for skill in $src/skills/$group/*/; do
        if [[ -f "$skill/SKILL.md" ]]; then
          cp -R "$skill" $out/share/skills/
        fi
      done
    done

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Matt Pocock's agent skills for real engineering";
    homepage = "https://github.com/mattpocock/skills";
    changelog = "https://github.com/mattpocock/skills/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
})
