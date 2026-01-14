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

  imports = [
    ./autocmds.nix
    ./colorscheme.nix
    ./keymaps.nix

    ./plugins
  ];

  config = lib.mkIf cfg.enable {

    programs.nixvim = {
      enable = true;

      opts = {
        # ================ General appearance ======================
        hidden = true; # Make Vim act like other editors; buffers can exist in the background without being in a window. http://items.sjbach.com/319/configuring-vim-right
        number = true; # Show line numbers
        relativenumber = false; # Show relative line numbers
        laststatus = 0; # Always display the status line
        history = 1000; # Store lots of command-line history
        showcmd = true; # Show incomplete commands at the bottom
        showmode = true; # Show the current mode at the bottom
        autoread = true; # Reload files changed outside Vim
        lazyredraw = true; # Redraw only when needed
        showmatch = true; # Highlight matching braces
        ruler = true; # Show the current line and column
        visualbell = true; # Use visual bell instead of sounds
        colorcolumn = "80,120"; # Show vertical lines at 80 and 120 characters
        listchars = "tab:→ ,trail:·,nbsp:·"; # Show special characters
        list = true; # Show special characters
        background = "dark"; # Set dark background
        termguicolors = true; # Enable 24-bit RGB colors
        signcolumn = "yes"; # Always show the sign column to avoid text shifting
        wrap = false; # Disable line wrapping
        cursorline = true; # Highlight the current line
        sidescrolloff = 8; # Keep 8 characters visible when scrolling horizontally
        scrolloff = 8; # Keep 8 lines visible when scrolling vertically

        # ================ Completion ======================
        completeopt = [
          "menuone"
          "noselect"
        ]; # Provide a better completion experience

        # ================ Conceal ======================
        conceallevel = 0; # Make `` visible in markdown files

        # ================ Persistent undo ==================
        undofile = true; # Enable persistent undo

        # ================ Indentation ======================
        autoindent = true; # Enable automatic indentation
        cindent = true; # Automatically indent braces
        smartindent = true; # Enable smart indentation
        smarttab = true; # Enable smart tab behavior
        shiftwidth = 2; # Set shift width to 2 spaces
        softtabstop = 2; # Set soft tab stop to 2 spaces
        tabstop = 2; # Set tab stop to 2 spaces
        expandtab = true; # Use spaces instead of tabs

        # ================ Splits ============================
        splitbelow = true; # Open horizontal splits below
        splitright = true; # Open vertical splits to the right

        # ================ Search and replace ========================
        incsearch = true; # Search incrementally as you type
        hlsearch = true; # Highlight search results
        ignorecase = true; # Ignore case in search patterns
        smartcase = true; # Override 'ignorecase' if search pattern contains uppercase
        inccommand = "split"; # Preview incremental substitutions in a split

        # ================ Movement ========================
        backspace = "indent,eol,start"; # Allow backspace in insert mode

        # ================ Spellchecking ========================
        spell = true; # Enable spellchecking
        spelllang = [ "en_us" ]; # Set spellchecking language
        spelloptions = "camel"; # Enable camel case spellchecking
      };

      highlight = {
        CursorLine = { };
        TrailingWhitespace = {
          bg = "red";
        };
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
        register = "unnamedplus";
      };

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      withNodeJs = true;
      withPython3 = true;
      withRuby = false;

      extraLuaPackages = ps: [
        ps.luarocks
        ps.tiktoken_core
      ];

      extraPlugins = with pkgs.vimPlugins; [
        undotree
      ];

      extraPackages = with pkgs; [
        # --- LSPs (Logic & Intelligence) ---
        bash-language-server
        gopls
        jsonnet-language-server
        lua-language-server
        nil
        terraform-ls
        yaml-language-server

        # --- Linters (Style & Safety) ---
        actionlint
        deadnix
        statix
        selene
        tflint
        yamllint
        markdownlint-cli
        shellcheck

        # --- Formatters (Code cleanup) ---
        go
        gotools
        nixfmt
        prettierd
        shfmt
        stylua
        yamlfmt
        topiary

        # --- Multi-tools (Lint + Format) ---
        ruff
        jq
      ];
    };
  };
}
