{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
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
  options.module.gpg-agent = {
    enable = mkEnableOption "GPG agent configuration";

    package = mkOption {
      type = types.package;
      default = pkgs.gnupg;
      description = "Modern release of the GNU Privacy Guard, a GPL OpenPGP implementation";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Configuration options to pass directly to 'services.gpg-agent'.
      '';
    };
  };

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
