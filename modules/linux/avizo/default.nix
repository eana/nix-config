{
  config,
  lib,
  ...
}:

let
  cfg = config.module.avizo;
in
{
  imports = [ ./interface.nix ];

  config = lib.mkIf cfg.enable {
    services.avizo = {
      enable = true;
      inherit (cfg) package settings;
    };
  };
}
