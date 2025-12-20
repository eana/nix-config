autopairs.nix:


_:

{
  programs.nixvim.plugins.nvim-autopairs = {
    enable = true;
    settings = {
      checkTs = true;
    };
  };
}


bufferline.nix:


_:

{
  programs.nixvim.plugins.bufferline = {
    enable = true;
    mode = "buffers";
    diagnostics = "nvim_lsp";
    indicator.style = null;

    #separatorStyle = "slant";
    closeIcon = "󰅚";
    bufferCloseIcon = "󰅙";
    modifiedIcon = "󰀨";

    offsets = [
      {
        filetype = "neo-tree";
        text = "File Explorer";
        text_align = "center";
        separator = false;
      }
    ];

    highlights = {
      indicatorSelected.fg = "#89b4fa";
      #tabSeparatorSelected.fg = "#89b4fa";
    };

    diagnosticsIndicator = ''
      function(count, level)
        local icon = level:match("error") and " " or ""
        return " " .. icon .. count
      end
    '';
  };
}


conform.nix:


_:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    formattersByFt = {
      "*" = [ "codespell" ];
      "_" = [ "trim_whitespace" ];
      #go = [ "goimports" "golines" "gofmt" "gofumpt" ];
      javascript = [ "prettierd" ];
      typescript = [ "prettierd" ];
      yaml = [ "prettierd" ];
      json = [ "jq" ];
      lua = [ "stylua" ];
      scss = [ "prettierd" ];
      css = [ "prettierd" ];
      python = [
        "isort"
        "black"
      ];
      rust = [ "rustfmt" ];
      sh = [ "shfmt" ];
      #terraform = [ "terraform_fmt" ];
    };
  };
}


dashboard.nix:


_:

{
  programs.nixvim.plugins.dashboard = {
    enable = true;
    header = [
      "███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗"
      "████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║"
      "██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║"
      "██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║"
      "██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║"
      "╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝"
    ];
  };
}


efmls.nix:


_:

{
  programs.nixvim.plugins.efmls-configs = {
    enable = false;
    setup.nix.formatter = "nixfmt";
    setup.scss.formatter = "prettier";
  };
}


keymaps.nix:


_:

{
  programs = {
    nixvim = {
      keymaps = [
        {
          key = "<leader>lf";
          action = "<cmd>lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";

          options = {
            silent = true;
          };
        }
        {
          key = ".";
          action = ":";
        }

        {
          key = "<leader>bb";
          action = "<CMD>Telescope file_browser<NL>";
        }

        {
          key = "<leader>t";
          action = "<CMD>Neotree<NL>";
        }

        {
          key = "<leader>w";
          action = "<CMD>WhichKey<NL>";
        }

        {
          key = "<Tab>";
          action = "<CMD>:bnext<NL>";
        }

        {
          key = "<leader>c";
          action = "<CMD>:bp | bd #<NL>";
        }
        {
          key = "<leader>c";
          action = "<CMD>:bp | bd #<NL>";
        }
      ];
    };
  };
}


lsp-format.nix:


_:

{
  programs.nixvim.plugins.lsp-format = {
    enable = false;
    lspServersToEnable = [
      "nixd"
      "efm"
    ];
  };
}


lsp.nix:


_:

{
  programs.nixvim.plugins.lsp = {
    enable = true;
    #keymaps.lspBuf = {
    #  "<leader>fm" = "format";
    #};
  };
}


lsp-servers.nix:


_:

{
  programs = {
    nixvim = {
      plugins = {
        lsp.servers.nixd.enable = true;
        lsp.servers.cssls.enable = true;
        lsp.servers.java-language-server.enable = true;
        lsp.servers.jsonls.enable = true;
        lsp.servers.lua-ls.enable = true;
        #lsp.servers.pylsp.enable = true;
        lsp.servers.rust-analyzer.enable = true;
        lsp.servers.rust-analyzer.installCargo = true;
        lsp.servers.rust-analyzer.installRustc = true;
        lsp.servers.tsserver.enable = false;
        lsp.servers.yamlls.enable = true;
        lsp.servers.efm.enable = true;
      };
    };
  };
}


neo-tree.nix:


_:

{
  programs.nixvim.plugins.neo-tree = {
    enable = true;
    autoCleanAfterSessionRestore = true;
    closeIfLastWindow = true;

    window = {
      position = "left";
    };

    filesystem = {
      followCurrentFile.enabled = true;
      filteredItems = {
        hideHidden = false;
        hideDotfiles = false;
        forceVisibleInEmptyFolder = true;
        hideGitignored = false;
      };
    };

    window.mappings = {
      "<bs>" = "navigate_up";
      "." = "set_root";
      "f" = "fuzzy_finder";
      "/" = "filter_on_submit";
      "h" = "show_help";
    };

    eventHandlers = {
      neo_tree_buffer_enter = ''
          function()
        vim.cmd 'highlight! Cursor blend=100'
        end
      '';
      neo_tree_buffer_leave = ''
          function()
        vim.cmd 'highlight! Cursor guibg=#5f87af blend=0'
        end
      '';
    };
  };
}


nvim-cmp.nix:


_:

{
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      extraOptions.sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
        { name = "luasnip"; }
        { name = "cmdline"; }
      ];

      settings.mapping = {
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-d>" = "cmp.mapping.scroll_docs(-4)";
        "<C-e>" = "cmp.mapping.close()";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
      };
      settings.snippet.expand = ''
        function(args)
        require('luasnip').lsp_expand(args.body)
        end
      '';
    };
    cmp-cmdline.enable = true;
  };
}


nvim.nix:


{ pkgs, ... }:

{
  imports = [
    ./keymaps.nix
    ./nvim-cmp.nix
    ./lsp.nix
    ./bufferline.nix
    ./telescope.nix
    ./neo-tree.nix
    ./prettier.nix
    ./lsp-servers.nix
    ./treesitter.nix
    ./autopairs.nix
    ./whichkey.nix
    ./dashboard.nix
    ./efmls.nix
    ./lsp-format.nix
    ./conform.nix
  ];
  programs = {
    nixvim = {
      enable = true;
      globals.mapleader = " ";
      clipboard.providers.wl-copy.enable = true;

      options = {
        number = true;
        relativenumber = false;
        shiftwidth = 2;
      };
      plugins = {
        nix.enable = true;

        lsp-lines.enable = true;
        lspkind.enable = true;

        neogit.enable = true;
        cmp-zsh.enable = true;
        noice.enable = true;
        nvim-colorizer.enable = true;
        luasnip.enable = true;
        rust-tools.enable = true;

        notify = {
          enable = true;
          #backgroundColour = "#000000";
          timeout = 2000;
          fps = 120;
          stages = "fade";
        };

        airline = {
          enable = true;
          #powerline = true;
          settings = {
            theme = "catppuccin";
          };
        };
      };

      #autoCmd = [
      #  {
      #    event = [ "BufWrite" ];
      #    pattern = [ "" ];
      #    command = "lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";
      #  }
      #];

      extraPlugins = with pkgs.vimPlugins; [
        telescope-ui-select-nvim
        #vim-autoformat
        vim-jsbeautify

      ];

      extraConfigLua =
        ''if vim.g.neovide then''
        + "\n"
        + ''vim.o.guifont = "Hurmit Nerd Font:h14"''
        + "\n"
        +

          ''vim.keymap.set('n', '<C-S-s>', ':w<CR>') -- Save''
        + "\n"
        + ''vim.keymap.set('v', '<C-S-c>', '"+y') -- Copy''
        + "\n"
        + ''vim.keymap.set('n', '<C-S-v>', '"+P') -- Paste normal mode''
        + "\n"
        + ''vim.keymap.set('v', '<C-S-v>', '"+P') -- Paste visual mode''
        + "\n"
        + ''vim.keymap.set('c', '<C-S-v>', '<C-R>+') -- Paste command mode''
        + "\n"
        + ''vim.keymap.set('i', '<C-S-v>', '<ESC>l"+Pli') -- Paste insert mode''
        + "\n"
        + "end";

      #colorschemes.kanagawa = {
      #  enable = true;
      #  terminalColors = true;
      #};

      #colorschemes.ayu = {
      #  enable = true;
      #  mirage = true;
      #};

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          transparentBackground = false;
        };
      };

    };
  };
}


prettier.nix:


_:

{
  programs.nixvim.plugins.none-ls.sources.formatting.prettier = {
    enable = true;
    disableTsServerFormatter = true;
  };
}


telescope.nix:


_:

{
  programs.nixvim.plugins.telescope = {
    enable = true;

    enabledExtensions = [ "ui-select" ];
    extensions.ui-select.enable = true;
    extensions.frecency.enable = false;
    extensions.fzf-native.enable = true;

    extensions.file-browser = {
      enable = true;
      settings.hidden = true;
      settings.depth = 9999999999;
      settings.auto_depth = true;
    };
    keymaps = {
      "<leader>ff" = "find_files";
      "<leader>fs" = "grep_string";
      "<leader>fg" = "live_grep";
    };
    settings = {
      pickers = {
        find_files = {
          hidden = true;
        };
      };
    };
  };
}


treesitter.nix:


_:

{
  programs.nixvim.plugins = {
    cmp-treesitter.enable = true;
    treesitter.enable = true;
    treesitter-refactor = {
      enable = true;
      highlightCurrentScope.enable = true;
      highlightCurrentScope.disable = [
        "nix"
      ];
      highlightDefinitions.enable = true;
      navigation.enable = true;
      smartRename.enable = true;
    };
  };
}


whichkey.nix:


_:

{
  programs.nixvim.plugins.which-key = {
    enable = true;
    icons = {
      separator = "";
      group = "";
    };
    keyLabels = {
      "<leader>" = "SPC";
    };
    registrations = {
      "<leader>c" = "󰅙 Close Buffer";
      "<leader>t" = "󰙅 FileExplorer";
      "<leader>f" = " Telescope";
      "<leader>w" = " WhichKey?!";
      "<leader>ff" = " Find Files";
      "<leader>l" = " LSP";
      "<leader>lf" = "󰉡 Format Buffer";
    };
  };
}
