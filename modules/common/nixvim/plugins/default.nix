{
  imports = [
    ./blink-cmp.nix
    ./bufferline.nix
    ./conform-nvim.nix
    ./copilot.nix
    ./d2.nix
    ./lint.nix
    ./lsp.nix
    ./lualine.nix
    ./snacks-nvim.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    plugins = {
      # --- UI/UX Enhancements ---
      better-comments.enable = true;
      indent-blankline = {
        enable = true;

        settings = {
          indent.char = "│";
          scope.enabled = false;
        };
      };
      mini = {
        enable = true;
        mockDevIcons = true;
        modules = {
          icons = { };
          indentscope = {
            symbol = "│";
            draw = {
              delay = 0;
              animation.__raw = "require('mini.indentscope').gen_animation.none()";
            };
          };
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
      trim.enable = true;
      web-devicons.enable = true;
      which-key = {
        enable = true;
        settings = {
          spec = [
            {
              __unkeyed-1 = "<leader><tab>";
              group = "tabs";
            }
            {
              __unkeyed-1 = "<leader>c";
              group = "code";
            }
            {
              __unkeyed-1 = "<leader>d";
              group = "debug";
            }
            {
              __unkeyed-1 = "<leader>dp";
              group = "profiler";
            }
            {
              __unkeyed-1 = "<leader>f";
              group = "file/find";
            }
            {
              __unkeyed-1 = "<leader>g";
              group = "git";
            }
            {
              __unkeyed-1 = "<leader>gh";
              group = "hunks";
            }
            {
              __unkeyed-1 = "<leader>q";
              group = "quit/session";
            }
            {
              __unkeyed-1 = "<leader>s";
              group = "search";
            }
            {
              __unkeyed-1 = "<leader>u";
              group = "ui";
            }
            {
              __unkeyed-1 = "<leader>x";
              group = "diagnostics/quickfix";
            }
            {
              __unkeyed-1 = "[";
              group = "prev";
            }
            {
              __unkeyed-1 = "]";
              group = "next";
            }
            {
              __unkeyed-1 = "g";
              group = "goto";
            }
            {
              __unkeyed-1 = "gs";
              group = "surround";
            }
            {
              __unkeyed-1 = "z";
              group = "fold";
            }
            {
              __unkeyed-1 = "<leader>b";
              group = "buffer";
            }
            {
              __unkeyed-1 = "<leader>w";
              group = "windows";
              proxy = "<C-w>";
            }
            {
              __unkeyed-1 = "gx";
              desc = "Open with system app";
            }
          ];
        };
      };

      # --- Editing Productivity ---
      nvim-autopairs.enable = true;

      # --- Search & Navigation ---
      grug-far = {
        enable = true;
        settings.headerMaxWidth = 80;
      };

      # --- Session/State Management ---
      persistence.enable = true;

      # --- Git Integration ---
      diffview.enable = true;
      gitsigns = {
        enable = true;
        settings = {
          signs = {
            add.text = "▎";
            change.text = "▎";
            delete.text = "";
            topdelete.text = "";
            changedelete.text = "▎";
            untracked.text = "▎";
          };
          signs_staged = {
            add.text = "▎";
            change.text = "▎";
            delete.text = "";
            topdelete.text = "";
            changedelete.text = "▎";
          };
        };
        luaConfig.post = ''
          require("snacks").toggle({
            name = "Git Signs",
            get = function()
              return require("gitsigns.config").config.signcolumn
            end,
            set = function(state)
              require("gitsigns").toggle_signs(state)
            end,
          }):map("<leader>uG")
        '';
      };

      # --- Diagnostics & Troubleshooting ---
      trouble.enable = true;

      # --- Lazy Loading/Performance ---
      lz-n.enable = true;
    };
  };
}
