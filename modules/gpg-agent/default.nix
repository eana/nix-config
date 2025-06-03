{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.gpg-agent;
  gpgAgentPkg = import ./package.nix { inherit lib pkgs; };

  defaultSettings = {
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    pinentryPackage = pkgs.pinentry-tty;
  };

in
{
  options.module.gpg-agent = {
    enable = mkEnableOption "GPG agent configuration";

    package = mkOption {
      type = types.package;
      default = gpgAgentPkg;
      description = "Customized GPG package";
    };

    settings = mkOption {
      type = types.submodule {
        options = {
          defaultCacheTtl = mkOption {
            type = types.int;
            default = defaultSettings.defaultCacheTtl;
            description = "Default cache TTL in seconds";
          };
          maxCacheTtl = mkOption {
            type = types.int;
            default = defaultSettings.maxCacheTtl;
            description = "Maximum cache TTL in seconds";
          };
          pinentryPackage = mkOption {
            type = types.package;
            default = defaultSettings.pinentryPackage;
            description = "Pinentry package to use";
          };
        };
      };
      default = defaultSettings;
      description = "GPG agent configuration settings";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      cfg.settings.pinentryPackage
    ];

    services.gpg-agent = {
      enable = true;
      inherit (cfg.settings) defaultCacheTtl maxCacheTtl;
      pinentry.package = cfg.settings.pinentryPackage;
    };
  };
}
