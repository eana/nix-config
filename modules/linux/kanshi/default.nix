{
  config,
  lib,
  ...
}:

let
  cfg = config.module.kanshi;
in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      inherit (cfg) settings;
    };
  };
}
