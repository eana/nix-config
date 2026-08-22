{
  config,
  lib,
  ...
}:

let
  cfg = config.module.gammastep;
in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    services.gammastep = {
      enable = true;
      inherit (cfg)
        tray
        provider
        latitude
        longitude
        temperature
        settings
        ;
    };
  };
}
