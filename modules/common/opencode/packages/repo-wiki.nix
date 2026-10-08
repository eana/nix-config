{
  makeWrapper,
  python3,
  runCommand,
}:
let
  # Skill doc lives with the other skills under assets/ and is the single
  # source of truth; the build copies it into $out so the package output is
  # itself a valid opencode skill directory (SKILL.md at the root).
  skillMd = ../../../../assets/.config/opencode/skills/repo-wiki/SKILL.md;

  pythonEnv = python3.withPackages (
    ps: with ps; [
      numpy
      requests
      tree-sitter
      tree-sitter-language-pack
    ]
  );

  build = ''
    mkdir -p $out/bin $out/share/repo-wiki

    cp ${./repo-wiki/repo-wiki-index.py} $out/share/repo-wiki/repo-wiki-index.py
    cp ${./repo-wiki/repo-wiki-query.py} $out/share/repo-wiki/repo-wiki-query.py
    cp ${skillMd} $out/SKILL.md

    makeWrapper ${pythonEnv}/bin/python3 $out/bin/repo-wiki-index \
      --add-flags "$out/share/repo-wiki/repo-wiki-index.py"
    makeWrapper ${pythonEnv}/bin/python3 $out/bin/repo-wiki-query \
      --add-flags "$out/share/repo-wiki/repo-wiki-query.py"
  '';
in
runCommand "repo-wiki" {
  nativeBuildInputs = [ makeWrapper ];
  meta = {
    description = "repo-wiki semantic index/query tools bundled with the opencode repo-wiki skill";
    mainProgram = "repo-wiki-index";
  };
} build
