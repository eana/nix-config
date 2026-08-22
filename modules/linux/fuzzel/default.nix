{
  config,
  lib,
  ...
}:

let
  cfg = config.module.fuzzel;

in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      inherit (cfg) package settings;
    };
  };
}
