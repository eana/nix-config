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
    rev = "v6.4.2";
    hash = "sha256-BWPiXoXV+jePP+wn/Z+Af4iehIL7oei00plaWaTzq8s=";
  };

  socialSkillsSrc = pkgs.fetchFromGitHub {
    owner = "inklate";
    repo = "social-skills";
    rev = "v0.1.0";
    hash = "sha256-ba6eKvREZ1a5WPKiXpWUUKD1cpAz7h0OF0hpIyTYXdY=";
  };

  localSkills = builtins.listToAttrs (
    map (name: {
      inherit name;
      value = ../../../assets/.config/opencode/skills/${name};
    }) catalog.local
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

  fullCatalog = localSkills // superpowersSkills // socialSkills;

  groupMembers = {
    superpowers = builtins.attrNames superpowersSkills;
    social = builtins.attrNames socialSkills;
  };

  expandedNames = lib.unique (
    lib.concatMap (
      name: if lib.hasAttr name groupMembers then groupMembers.${name} else [ name ]
    ) enabledSkills
  );
in
lib.filterAttrs (name: _: builtins.elem name expandedNames) fullCatalog
