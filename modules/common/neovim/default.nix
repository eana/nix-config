{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.neovim;

  nvimConfigDir = ../../../assets/.config/nvim;

  commonDeps = with pkgs; [
    gcc # GNU Compiler Collection
    gnumake # Build automation tool
    python3 # Python programming language

    aider-chat # AI pair programming in terminal
    go # Go programming language
    gotools # Tools for Go programming
    nil # Nix language server
    tree-sitter # Incremental parsing system
    unzip # Utility for unpacking zip files
  ];

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
    home.sessionVariables = {
      AIDER_MODEL = lib.mkDefault "openrouter/deepseek/deepseek-r1:free";

      AIDER_AUTO_COMMITS = lib.mkDefault "0";
      AIDER_GITIGNORE = lib.mkDefault "0";

      AIDER_INPUT_HISTORY_FILE = lib.mkDefault "$HOME/.config/aider/.aider.input.history";
      AIDER_CHAT_HISTORY_FILE = lib.mkDefault "$HOME/.config/aider/.aider.chat.history.md";
      AIDER_LLM_HISTORY_FILE = lib.mkDefault "$HOME/.config/aider/.aider.llm.history.md";
    };

    home.packages =
      with pkgs;
      [
        (lib.mkIf cfg.withNodeJs nodejs)
      ]
      ++ commonDeps
      ++ cfg.extraPackages;

    xdg.configFile = {
      ".aider/.keep".text = "";
      "nvim" = {
        source = nvimConfigDir;
        recursive = true;
      };
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
