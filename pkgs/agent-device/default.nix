{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  nodejs_24,
  makeWrapper,
  nix-update-script,
  testers,
}:
let
  mkSkill =
    version: name: hash:
    stdenvNoCC.mkDerivation {
      pname = "agent-device-skill-${name}";
      inherit version;
      src = fetchurl {
        url = "https://raw.githubusercontent.com/callstack/agent-device/v${version}/skills/${name}/SKILL.md";
        inherit hash;
      };
      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp $src $out/SKILL.md

        runHook postInstall
      '';
    };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "agent-device";
  version = "0.21.36";

  src = fetchurl {
    url = "https://registry.npmjs.org/agent-device/-/agent-device-${finalAttrs.version}.tgz";
    hash = "sha256-Cq2Ia0fQal7KjlTTKpdmmF8jKD9JrcHFBFUJoZG8pco=";
  };

  sourceRoot = "package";

  skill-agent-device =
    mkSkill finalAttrs.version "agent-device"
      "sha256-HxfEyE3Xc3v5DlGSWa6mDeGgNKVYbkRMdRJFU8wuUk0=";
  skill-android-emulator =
    mkSkill finalAttrs.version "android-emulator"
      "sha256-qqqt/Dukpl6lYb/5gm8ii4Wa0rUck8JEPcXljAwcjJs=";
  skill-dogfood =
    mkSkill finalAttrs.version "dogfood"
      "sha256-GaeoZxqRKcTYobu34xCAkEn8C5/TM0K0Nheavcnf0y0=";
  skill-ios-simulator =
    mkSkill finalAttrs.version "ios-simulator"
      "sha256-AFHpzqvEMOEzyGAM3zwx9Jhezc/Y2f6Kj+3gjL65psA=";

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/agent-device $out/bin
    cp -R -- . $out/lib/agent-device

    makeWrapper ${lib.getExe nodejs_24} $out/bin/agent-device \
      --add-flags "$out/lib/agent-device/bin/agent-device.mjs"

    mkdir -p $out/share/skills
    cp -R ${finalAttrs.skill-agent-device} $out/share/skills/agent-device
    cp -R ${finalAttrs.skill-android-emulator} $out/share/skills/android-emulator
    cp -R ${finalAttrs.skill-dogfood} $out/share/skills/dogfood
    cp -R ${finalAttrs.skill-ios-simulator} $out/share/skills/ios-simulator

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs)
      skill-agent-device
      skill-android-emulator
      skill-dogfood
      skill-ios-simulator
      ;
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage=skill-agent-device"
        "--subpackage=skill-android-emulator"
        "--subpackage=skill-dogfood"
        "--subpackage=skill-ios-simulator"
      ];
    };
    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };
  };

  meta = with lib; {
    description = "Open source device layer for AI coding agents: a CLI, MCP server, and typed Node.js API to control mobile, web, TV, and desktop apps on devices and simulators, locally or in the cloud.";
    homepage = "https://agent-device.dev";
    changelog = "https://github.com/callstack/agent-device/releases/tag/v${finalAttrs.version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "agent-device";
    platforms = platforms.all;
  };
})
