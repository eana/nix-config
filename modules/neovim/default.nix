{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.neovim;

  nvimConfigDir = ../../assets/.config/nvim;

in
{
  options.module.neovim = {
    enable = mkEnableOption "Neovim text editor";

    vimAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create a 'vim' alias for Neovim";
    };

    withNodeJs = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Node.js support";
    };

    defaultEditor = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to set Neovim as the default editor";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Neovim configuration to append";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "List of Neovim plugins to install";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional runtime dependencies";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        (lib.mkIf cfg.withNodeJs nodejs)
      ]
      ++ cfg.extraPackages;

    xdg.configFile."nvim" = {
      source = nvimConfigDir;
      recursive = true;
    };

    programs.neovim = {
      enable = true;
      inherit (cfg)
        vimAlias
        withNodeJs
        defaultEditor
        plugins
        ;

      inherit (cfg) extraConfig;
    };
  };
}
