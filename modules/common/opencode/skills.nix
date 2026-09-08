{
  lib,
  pkgs,
  enableLinkedin ? false,
  enableSocial ? false,
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

  socialSkillsSrc = pkgs.fetchFromGitHub {
    owner = "inklate";
    repo = "social-skills";
    rev = "v0.1.0";
    hash = "sha256-ba6eKvREZ1a5WPKiXpWUUKD1cpAz7h0OF0hpIyTYXdY=";
  };

  socialSkillsList = [
    "idk"
    "social-context"
    "social-voice"
    "social-post"
    "social-thread"
    "social-carousel"
    "social-hook"
    "social-crosspost"
    "social-repurpose"
    "social-reply"
    "social-ad"
    "social-calendar"
    "social-audit"
    "social-check"
  ];

  socialSkills = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = "${socialSkillsSrc}/skills/${name}";
    }) socialSkillsList
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
// lib.optionalAttrs enableSocial socialSkills
