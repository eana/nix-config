{
  config,
  inputs,
  lib,
  ...
}:
{
  home-manager = {
    users.jonas = {
      _module.args = {
        sshSecretsPath = config.age.secrets.ssh-hosts.path;
        atuinSecretsPath = config.age.secrets.atuin.path;
      };
      imports = [
        ../../../home/users/jonas/darwin.nix
        ../../../modules/darwin/aerospace
        ./file-associations.nix
        ./karabiner.nix
        ./nightlight.nix
      ]
      ++ import ../../shared/home-manager/base.nix {
        inherit inputs;
        modulesFromDir = lib.eana.modulesFromDir;
        modulesDir = ../../../modules/common;
      };
      home.stateVersion = "26.05";
      home.enableNixpkgsReleaseCheck = false;
    };

    extraSpecialArgs = {
      inherit inputs;
      nixvimInput = inputs.nixvim;
    };
  };
}
