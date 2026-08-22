{ lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    literalExpression
    ;

  clipboardPackage = if pkgs.stdenv.hostPlatform.isLinux then pkgs.wl-clipboard else null;

  defaultClipboardCmd =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "pbcopy"
    else if pkgs.stdenv.hostPlatform.isLinux then
      "${clipboardPackage}/bin/wl-paste"
    else
      "";
in
{
  options.module.tmux = {
    enable = mkEnableOption "tmux terminal multiplexer";

    package = mkOption {
      type = types.package;
      default = pkgs.tmux;
      defaultText = literalExpression "pkgs.tmux";
      description = "Terminal multiplexer";
    };

    shortcut = mkOption {
      type = types.str;
      default = "a";
      description = "Base shortcut key for tmux commands";
    };

    baseIndex = mkOption {
      type = types.int;
      default = 1;
      description = "Base index for windows and panes";
    };

    clock24 = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use 24-hour clock";
    };

    escapeTime = mkOption {
      type = types.int;
      default = 0;
      description = "Time in milliseconds for which tmux waits after an escape is input";
    };

    secureSocket = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use secure socket";
    };

    historyLimit = mkOption {
      type = types.int;
      default = 999999999;
      description = "Maximum number of lines kept in history";
    };

    keyMode = mkOption {
      type = types.enum [
        "vi"
        "emacs"
      ];
      default = "vi";
      description = "Key binding mode (vi or emacs)";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.tmuxPlugins.resurrect ];
      description = "List of tmux plugins to install";
    };

    clipboard = {
      command = mkOption {
        type = types.str;
        default = defaultClipboardCmd;
        description = ''
          Command for clipboard integration (e.g., "wl-paste", "pbcopy").
          For WSL, "clip.exe" is handled internally by default.
        '';
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional tmux configuration";
    };
  };
}
