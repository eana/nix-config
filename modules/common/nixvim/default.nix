{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.nixvim;

in
{
  imports = [
    ./options
    ./plugins
    ./themes
  ];

  options.module.nixvim = {
    enable = mkEnableOption "NixVim text editor";

    viAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create a 'vi' alias for NixVim";
    };

    vimAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create a 'vim' alias for NixVim";
    };

    withNodeJs = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Node.js support";
    };

    withRuby = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Ruby support";
    };

    withPython3 = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Python 3 support";
    };

    clipboard = {
      register = mkOption {
        type = types.str;
        default = "unnamedplus";
        description = "Clipboard register to use";
      };

      providers = {
        wl-copy = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable wl-copy clipboard provider";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      inherit (cfg) viAlias;
      inherit (cfg) vimAlias;
      inherit (cfg) withNodeJs;
      inherit (cfg) withRuby;
      inherit (cfg) withPython3;
      clipboard = {
        inherit (cfg.clipboard) register;
        providers.wl-copy.enable = cfg.clipboard.providers.wl-copy.enable;
      };
    };
  };
}
