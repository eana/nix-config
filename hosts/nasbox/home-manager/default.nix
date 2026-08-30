{ inputs, ... }:
let
  eanaLib = import ../../../lib.nix { lib = inputs.nixpkgs.lib; };
in
{
  imports = [
    ../../../home/users/root/ds920p.nix
    inputs.nixvim.homeModules.nixvim
  ]
  ++ builtins.attrValues (eanaLib.modulesFromDir ../../../modules/common);

  home.username = "root";
  home.homeDirectory = "/root";
}
