{
  lib,
  pkgs,
  enableLinkedin ? false,
}:
let
  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v6.3.0";
    hash = "sha256-EsGNO0dULWf5Bx6bGrCv2kI2Z8aKH0kRvGiuN23wChQ=";
  };

  superpowersSkillsList = [
    "brainstorming"
    "dispatching-parallel-agents"
    "executing-plans"
    "finishing-a-development-branch"
    "receiving-code-review"
    "requesting-code-review"
    "subagent-driven-development"
    "systematic-debugging"
    "test-driven-development"
    "using-git-worktrees"
    "using-superpowers"
    "verification-before-completion"
    "writing-plans"
    "writing-skills"
  ];

  superpowersSkills = builtins.listToAttrs (
    map (name: {
      name = "superpowers-${name}";
      value = "${superpowersSrc}/skills/${name}";
    }) superpowersSkillsList
  );
in
{
  # keep-sorted start
  flake-parts = ../../../assets/.config/opencode/skills/flake-parts;
  ghq-lookup = ../../../assets/.config/opencode/skills/ghq-lookup;
  git-commit = ../../../assets/.config/opencode/skills/git-commit;
  gitlab-cli-tool = ../../../assets/.config/opencode/skills/gitlab-cli-tool;
  nix-check = ../../../assets/.config/opencode/skills/nix-check;
  nix-coding = ../../../assets/.config/opencode/skills/nix-coding;
  nix-config = ../../../assets/.config/opencode/skills/nix-config;
  skill-creator = ../../../assets/.config/opencode/skills/skill-creator;
  style = ../../../assets/.config/opencode/skills/style;
  # keep-sorted end
}
// superpowersSkills
// lib.optionalAttrs enableLinkedin {
  linkedin-profile-editor = ../../../assets/.config/opencode/skills/linkedin-profile-editor;
}
