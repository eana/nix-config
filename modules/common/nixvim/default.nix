{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.module.nixvim;
in
{
  options.module.nixvim = {
    enable = lib.mkEnableOption "nixvim";
  };

  imports = [ ./plugins ];

  config = lib.mkIf cfg.enable {

    programs.nixvim = {
      enable = true;

      opts = {
        number = true;
        relativenumber = false;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;

        spell = true;
        spelllang = [ "en_us" ];
        spelloptions = "camel";
      };

      highlight = {
        SpellBad = {
          underline = true;
          fg = "#E06C75";
        };
      };

      clipboard = {
        providers = {
          wl-copy.enable = pkgs.stdenv.isLinux;
          pbcopy.enable = pkgs.stdenv.isDarwin;
        };
      };

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraPlugins = with pkgs.vimPlugins; [
        undotree
      ];
    };
  };
}
