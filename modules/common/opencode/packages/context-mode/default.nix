{
  lib,
  stdenv,
  fetchurl,
  installAgentSkills,
}:

# Packaged locally rather than taken from pkgs.context-mode, which is stuck on
# 1.0.143 and omits opencode/plugin.js (its main/exports entry), so opencode
# never loads it. Still local because nixpkgs has not caught up to the 2.0.0
# bundled layout.
# TODO: replace with pkgs.context-mode once it tracks current upstream releases.
stdenv.mkDerivation (finalAttrs: {
  pname = "context-mode";
  version = "2.1.6";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${finalAttrs.version}.tgz";
    hash = "sha256-RroRlHEq1vXURTAfbDVHPdeMln/8wk/YhOJkechZ2AE=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [
    installAgentSkills
  ];

  dontBuild = true;

  # HACK: auto-glob installs every **/SKILL.md, hitting duplicate "context-mode"
  # skills under claude-code/, codex/ and pi/ (other agents' bundles) and
  # hard-failing the build. Scoped manually to skills/*/ below instead.
  # TODO: drop this and the loop if the setup hook gains an exclusion, or
  # context-mode stops shipping the duplicates.
  dontInstallAgentSkills = 1;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/context-mode
    cp -r \
      opencode \
      server.mjs \
      cli.mjs \
      hook.mjs \
      hooks \
      skills \
      package.json \
      LICENSE \
      README.md \
      $out/lib/context-mode/

    # The three real agent skills (see dontInstallAgentSkills above).
    for skill in skills/*/; do installSkill "$skill"; done

    runHook postInstall
  '';

  meta = {
    description = "Context window optimization plugin and MCP server for AI coding agents";
    homepage = "https://github.com/mksglu/context-mode";
    license = lib.licenses.elastic20;
    platforms = lib.platforms.all;
  };
})
