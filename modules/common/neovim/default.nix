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

  cfg = config.module.neovim;

  # Nushell Topiary support
  nu-scm = pkgs.fetchFromGitHub {
    owner = "blindFS";
    repo = "topiary-nushell";
    rev = "main";
    sha256 = "sha256-rV0BNLVg+cKJtAprKLPLpfwOvYjCSMjfCKzS/kSUFu0=";
  };

  # Tools required specifically for plugin compilation (e.g., CopilotChat.nvim)
  compilationTools = with pkgs; [
    gcc
    gnumake
    unzip
  ];

  # Core Language Servers and Formatters
  lspAndFormatters = with pkgs; [
    bash-language-server
    black
    gopls
    gotools
    jsonnet-language-server
    lua-language-server
    nil
    nixfmt-rfc-style
    prettierd
    shellcheck
    shfmt
    stylua
    terraform-ls
    tflint
    yaml-language-server
    yamlfmt
  ];

  # Integrated CLI tools
  integratedClis = with pkgs; [
    aider-chat-with-playwright
    glow
    topiary
    tree-sitter
    go
    python3
    nodejs_22
  ];

in
{
  options.module.neovim = {
    enable = mkEnableOption "Neovim text editor";

    configDir = mkOption {
      type = types.path;
      default = ../../../assets/.config/nvim;
      description = "Path to the nvim configuration directory (init.lua, etc.)";
    };

    aider = {
      model = mkOption {
        type = types.str;
        default = "openrouter/deepseek/deepseek-r1:free";
      };
    };

    vimAlias = mkOption {
      type = types.bool;
      default = true;
    };

    defaultEditor = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      AIDER_MODEL = lib.mkDefault "openrouter/deepseek/deepseek-r1:free";

      AIDER_AUTO_COMMITS = lib.mkDefault "0";
      AIDER_GITIGNORE = lib.mkDefault "0";

      AIDER_INPUT_HISTORY_FILE = lib.mkDefault "$HOME/.config/aider/.aider.input.history";
      AIDER_CHAT_HISTORY_FILE = lib.mkDefault "$HOME/.config/aider/.aider.chat.history.md";
      AIDER_LLM_HISTORY_FILE = lib.mkDefault "$HOME/.config/aider/.aider.llm.history.md";

      TOPIARY_CONFIG_FILE = lib.mkDefault "$HOME/.config/topiary/languages.ncl";
      TOPIARY_LANGUAGE_DIR = lib.mkDefault "$HOME/.config/topiary/languages";
    };

    # System-level dependencies for LSPs, Compilers, and CLI tools
    home.packages = compilationTools ++ lspAndFormatters ++ integratedClis;

    xdg.configFile = {
      "nvim" = {
        source = cfg.configDir;
        recursive = true;
      };
      "topiary/languages.ncl".source = "${nu-scm}/languages.ncl";
      "topiary/languages/nu.scm".source = "${nu-scm}/languages/nu.scm";
    };

    programs.neovim = {
      enable = true;
      inherit (cfg) vimAlias defaultEditor;

      withNodeJs = true;
      withPython3 = true;
      withRuby = false;

      extraLuaPackages = ps: [
        ps.luarocks
        ps.tiktoken_core
      ];
    };
  };
}
