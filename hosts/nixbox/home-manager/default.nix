{
  pkgs,
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
        ../../../home/users/jonas/linux.nix
      ]
      ++ import ../../shared/home-manager/base.nix {
        inherit inputs;
        modulesFromDir = lib.eana.modulesFromDir;
        modulesDir = ../../../modules/common;
      }
      ++ builtins.attrValues (
        lib.filterAttrs (name: _: name != "libvirt") (lib.eana.modulesFromDir ../../../modules/linux)
      );
    };

    extraSpecialArgs = {
      inherit inputs;
      nixvimInput = inputs.nixvim;
    };
  };

  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "wheel"
      "ydotool"
    ];
  };

  users.defaultUserShell = pkgs.zsh;
}
