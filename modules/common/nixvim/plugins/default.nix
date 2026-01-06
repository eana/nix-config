{
  imports = [
    ./bufferline.nix
    ./colorscheme.nix
    ./conform-nvim.nix
    ./copilot.nix
    ./d2.nix
    ./fzf-lua.nix
    ./lint.nix
    ./lsp.nix
    ./lualine.nix
    ./persistence.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    plugins = {
      # Lazy loading
      lz-n.enable = true;

      better-comments.enable = true;

      web-devicons.enable = true;
      which-key.enable = true;

      blink-cmp = {
        enable = true;
        settings = {
          # https://github.com/saghen/blink.cmp/blob/main/doc/configuration/keymap.md#presets
          keymap.preset = "enter";

          appearance = {
            nerd_font_variant = "mono";
          };

          sources = {
            default = [
              "lsp"
              "path"
              "snippets"
              "buffer"
            ];
          };

          cmdline = {
            sources = [
              "buffer"
              "cmdline"
            ];
          };

          completion = {
            list = {
              selection = {
                preselect = true;
                auto_insert = false;
              };
            };
            menu = {
              auto_show = true;
              border = "rounded";
            };
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 500;
            };
            ghost_text = {
              enabled = false;
            };
          };
        };
      };

      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          filesystem = {
            follow_current_file = {
              enabled = true;
            };
            filtered_items = {
              visible = true;
              hide_dotfiles = false;
              hide_gitignored = false;
              hide_hidden = false;
            };
          };
        };
      };
      grug-far.enable = true;
      trouble.enable = true;

      mini = {
        enable = true;
        mockDevIcons = true;

        modules = {
          icons = { };
          surround = {
            mappings = {
              add = "gsa";
              delete = "gsd";
              find = "gsf";
              find_left = "gsF";
              highlight = "gsh";
              replace = "gsr";
              update_n_lines = "gsn";
            };
          };
        };
      };

      snacks = {
        enable = true;
        settings = {
          bufdelete.enabled = true;
        };
      };

      nvim-autopairs.enable = true;
      gitsigns = {
        enable = true;
        settings.signs = {
          add.text = "+";
          change.text = "~";
        };
        keymaps = {
          "]c" = {
            action.__raw = ''
              function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() require('gitsigns').nav_hunk('next') end)
                return '<Ignore>'
              end
            '';
            options = {
              expr = true;
              desc = "Next Hunk";
            };
          };

          "[c" = {
            action.__raw = ''
              function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() require('gitsigns').nav_hunk('prev') end)
                return '<Ignore>'
              end
            '';
            options = {
              expr = true;
              desc = "Previous Hunk";
            };
          };
        };
      };
      diffview.enable = true;
      trim = {
        enable = true;
        settings = {
          highlight = true;
          ft_blocklist = [
            "checkhealth"
            "floaterm"
            "lspinfo"
            "neo-tree"
            "TelescopePrompt"
          ];
        };
      };
    };
  };
}
