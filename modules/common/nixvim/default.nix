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
        conceallevel = 0; # Make `` visible in markdown files
        signcolumn = "yes"; # Always show the sign column to avoid text shifting
        completeopt = [
          "menuone"
          "noselect"
        ]; # Provide a better completion experience
        wrap = false; # Disable line wrapping
        cursorline = true; # Highlight the current line

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

      extraPlugins = with pkgs.vimPlugins; [
        undotree
      ];

      extraConfigLua = ''
        vim.cmd([[highlight TrailingWhitespace ctermbg=red guibg=red]])
        vim.cmd([[match TrailingWhitespace /\s\+$/]])
      '';

      # Highlight on yanking
      autoGroups = {
        highlight-yank = {
          clear = true;
        };
      };
      autoCmd = [
        {
          event = [ "TextYankPost" ];
          desc = "Highlight when yanking (copying) text";
          group = "highlight-yank";
          callback.__raw = ''
            function()
              vim.highlight.on_yank()
            end
          '';
        }
      ];
    };
  };
}
