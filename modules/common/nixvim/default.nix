{ config, lib, ... }:

{
  options.module.nixvim.enable = lib.mkEnableOption "nixvim configuration";

  imports = [ ./nvim.nix ];
}
