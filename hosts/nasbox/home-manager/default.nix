{ inputs, ... }:
let
  eanaLib = import ../../../lib.nix { lib = inputs.nixpkgs.lib; };
in
{
  imports = [
    ../../../home/users/root/ds920p.nix
  ]
  ++ import ../../shared/home-manager/base.nix {
    inherit inputs;
    inherit (eanaLib) modulesFromDir;
    modulesDir = ../../../modules/common;
  };

  home.username = "root";
  home.homeDirectory = "/root";
}
