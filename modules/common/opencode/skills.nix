{
  lib,
  pkgs,
  enabledSkills ? [ ],
  ticketsRepo,
}:
let
  catalog = import ./skills-catalog.nix;

  ticketTaskSrc = ../../../assets/.config/opencode/skills/ticket-task;

  ticketTaskSkill = pkgs.runCommand "opencode-skill-ticket-task" { TICKETS_REPO = ticketsRepo; } ''
    cp -r ${ticketTaskSrc} $out
    chmod -R u+w $out
    substituteInPlace $out/SKILL.md $out/references/workflow.md \
      --replace-fail 'eana/agent-tickets' "$TICKETS_REPO"
  '';

  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v7.0.1";
    hash = "sha256-9+69YEdjdaDu5sWTyAbufSVcZgGD7h6wAq4nUVY2syE=";
  };

  socialSkillsSrc = pkgs.fetchFromGitHub {
    owner = "inklate";
    repo = "social-skills";
    rev = "v0.1.0";
    hash = "sha256-ba6eKvREZ1a5WPKiXpWUUKD1cpAz7h0OF0hpIyTYXdY=";
  };

  anthropicSkillsSrc = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "ca45fc496a3436251f191354091d557da31c15b5";
    hash = "sha256-MkCOANBAqCc1WmNf7S8PsyAphGJAIzEXGyCm8RrCR9M=";
  };

  localSkills = builtins.listToAttrs (
    map (name: {
      inherit name;
      value =
        if name == "ticket-task" then ticketTaskSkill else ../../../assets/.config/opencode/skills/${name};
    }) catalog.local
  );

  anthropicSkills = builtins.listToAttrs (
    map (name: {
      name = "skill-creator";
      value = "${anthropicSkillsSrc}/skills/${name}";
    }) catalog.anthropic
  );

  superpowersSkills = builtins.listToAttrs (
    map (name: {
      name = "superpowers-${name}";
      value = "${superpowersSrc}/skills/${name}";
    }) catalog.superpowers
  );

  socialSkills = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = "${socialSkillsSrc}/skills/${name}";
    }) catalog.social
  );

  fullCatalog = localSkills // anthropicSkills // superpowersSkills // socialSkills;

  groupMembers = {
    superpowers = builtins.attrNames superpowersSkills;
    social = builtins.attrNames socialSkills;
    anthropic = builtins.attrNames anthropicSkills;
  };

  expandedNames = lib.unique (
    lib.concatMap (
      name: if lib.hasAttr name groupMembers then groupMembers.${name} else [ name ]
    ) enabledSkills
  );
in
lib.filterAttrs (name: _: builtins.elem name expandedNames) fullCatalog
