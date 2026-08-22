{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    ;

  cfg = config.module.gpg-agent;

  defaultGpgSettings = {
    defaultCacheTtl = lib.mkDefault 86400;
    maxCacheTtl = lib.mkDefault 86400;
    pinentry.package = lib.mkDefault pkgs.pinentry-tty;
  };

in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    services.gpg-agent = lib.mkMerge [
      defaultGpgSettings
      cfg.settings
      {
        enable = true;
      }
    ];

    home.packages = [ cfg.package ];
  };
}
