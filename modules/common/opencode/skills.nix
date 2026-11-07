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
    rev = "v7.0.2";
    hash = "sha256-rP5YsyGuPd9YSW/Fj3aukrq1bLuV+nwwQMK4JaZQgkI=";
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
    rev = "2c5958ecac7cee2b583967a2c4981d0f4a75c579";
    hash = "sha256-dRCZrNarCCJFuvATgfW6qmwwVS5HGFXNVGOhbVZd7LA=";
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
