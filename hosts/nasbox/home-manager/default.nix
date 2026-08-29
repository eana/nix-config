{ inputs, config, ... }:
let
  eanaLib = import ../../../lib.nix { lib = inputs.nixpkgs.lib; };
in
{
  imports = [
    ../../../home/users/root/ds920p.nix
    inputs.nixvim.homeModules.nixvim
  ]
  ++ builtins.attrValues (eanaLib.modulesFromDir ../../../modules/common);

  age.secrets.atuin = {
    file = ../../../secrets/atuin.age;
    mode = "0400";
  };

  _module.args.atuinSecretsPath = config.age.secrets.atuin.path;

  home.username = "root";
  home.homeDirectory = "/root";
}
