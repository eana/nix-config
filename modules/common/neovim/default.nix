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

  nu-scm = pkgs.fetchFromGitHub {
    owner = "blindFS";
    repo = "topiary-nushell";
    rev = "main";
    sha256 = "sha256-rV0BNLVg+cKJtAprKLPLpfwOvYjCSMjfCKzS/kSUFu0=";
  };

  commonDeps = with pkgs; [
    gcc # GNU Compiler Collection
    gnumake # Build automation tool
    go # Go programming language
    nu-scm # Nushell with Topiary support
    python3 # Python programming language

    aider-chat-with-playwright # AI pair programming in terminal
    glow # Markdown renderer for the terminal
    unzip # Utility for unpacking zip files

    # Linters, formatters, and language servers
    bash-language-server # Language server for Bash
    black # Python code formatter
    gopls # Go language server
    gotools # Tools for Go programming
    jsonnet-language-server # Language server for Jsonnet
    lua # Lua programming language
    lua-language-server # Language server for Lua
    luajitPackages.luarocks # Package manager for Lua modules
    luajitPackages.tiktoken_core # Tokenizer for Lua
    nil # Nix language server
    nixfmt-rfc-style # Nix code formatter
    nodejs_22 # JavaScript runtime
    prettierd # Prettier for formatting code
    shellcheck # Shell script analysis tool
    shfmt # Shell script formatter
    stylua # Lua code formatter
    terraform-ls # Language server for Terraform
    tflint # Terraform linter
    topiary # Uniform formatter for simple languages
    tree-sitter # Incremental parsing system
    yaml-language-server # Language server for YAML
    yamlfmt # YAML formatter
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

      TOPIARY_CONFIG_FILE = lib.mkDefault "$HOME/.config/topiary/languages.ncl";
      TOPIARY_LANGUAGE_DIR = lib.mkDefault "$HOME/.config/topiary/languages";
    };

    home.packages =
      with pkgs;
      [
        (lib.mkIf cfg.withNodeJs nodejs)
      ]
      ++ commonDeps
      ++ cfg.extraPackages;

    xdg.configFile = {
      "nvim" = {
        source = nvimConfigDir;
        recursive = true;
      };
      "topiary/languages.ncl".source = "${nu-scm}/languages.ncl";
      "topiary/languages/nu.scm".source = "${nu-scm}/languages/nu.scm";
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
