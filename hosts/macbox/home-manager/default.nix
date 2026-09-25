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
        inputs.nixvim.homeModules.nixvim
        ../../../modules/darwin/aerospace
        ./karabiner.nix
        ./nightlight.nix
      ]
      ++ builtins.attrValues (lib.eana.modulesFromDir ../../../modules/common);
      home.stateVersion = "26.05";
      home.enableNixpkgsReleaseCheck = false;
    };

    extraSpecialArgs = {
      inherit inputs;
      nixvimInput = inputs.nixvim;
    };
  };
}
