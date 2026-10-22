{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "i-have-adhd";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "ayghri";
    repo = "i-have-adhd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GTqrnZxQvzo/ogAuUrffkOaMK1BYm/4rAZsnfmDt7DU=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/skills
    cp -R $src/skills/i-have-adhd $out/share/skills/

    mkdir -p $out/share/opencode-commands
    cp $src/.opencode/command/i-have-adhd.md $out/share/opencode-commands/i-have-adhd.md

    mkdir -p $out/share/opencode/plugins
    cp $src/.opencode/plugins/i-have-adhd.js $out/share/opencode/plugins/
    cp $src/.opencode/plugins/i-have-adhd.mjs $out/share/opencode/plugins/

    # Upstream resolves the skill/command relative to a repo checkout
    # (../../skills, ../command), which breaks once the files are installed
    # to the store. Point them at the absolute store paths instead so the
    # plugin works when symlinked into ~/.config/opencode/plugins/.
    substituteInPlace $out/share/opencode/plugins/i-have-adhd.mjs \
      --replace-fail "const skillsDir = path.resolve(__dirname, '../../skills');" "const skillsDir = \"$out/share/skills\";" \
      --replace-fail "const commandPath = path.join(__dirname, '..', 'command', 'i-have-adhd.md');" "const commandPath = \"$out/share/opencode-commands/i-have-adhd.md\";"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "ADHD-friendly output style for AI coding agents (opencode plugin + skill)";
    homepage = "https://github.com/ayghri/i-have-adhd";
    changelog = "https://github.com/ayghri/i-have-adhd/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
})
