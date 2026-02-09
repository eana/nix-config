{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.opencode;

  defaultSettings = {
    "$schema" = "https://opencode.ai/config.json";
    autoshare = false;
    autoupdate = false;
    experimental = {
      disable_paste_summary = true;
    };
    keybinds = {
      session_export = "none";
      session_share = "none";
      session_unshare = "none";
      terminal_suspend = "none";
      messages_first = "ctrl+home";
      messages_last = "ctrl+end";
    };
    share = "disabled";
  };

in
{
  options.module.opencode = {
    enable = mkEnableOption "OpenCode AI coding agent";

    package = mkOption {
      type = types.package;
      default = pkgs.opencode;
      description = "The open source AI coding agent";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "OpenCode configuration settings";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."opencode/config.json".text = builtins.toJSON (
      lib.recursiveUpdate defaultSettings cfg.settings
    );
  };
}
