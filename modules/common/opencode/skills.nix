{
  lib,
  pkgs,
  enabledSkills ? [ ],
}:
let
  catalog = import ./skills-catalog.nix;

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
      value = ../../../assets/.config/opencode/skills/${name};
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
