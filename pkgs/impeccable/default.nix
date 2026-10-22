{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "impeccable";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "pbakaus";
    repo = "impeccable";
    tag = "skill-v${finalAttrs.version}";
    hash = "sha256-E6rGF4Qu1TZsO959h2DZDNkfz81TDaSIF1O6ssiHIyQ=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/skills
    cp -R $src/.opencode/skills/impeccable $out/share/skills/

    mkdir -p $out/share/opencode-commands
    cp $src/.opencode/commands/impeccable.md $out/share/opencode-commands/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=skill-v(.*)" ];
  };

  meta = with lib; {
    description = "Design skills, commands, and anti-pattern detection for AI coding agents";
    homepage = "https://github.com/pbakaus/impeccable";
    changelog = "https://github.com/pbakaus/impeccable/releases/tag/skill-v${finalAttrs.version}";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.all;
  };
})
