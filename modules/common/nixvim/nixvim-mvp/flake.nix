{
  description = "Minimal nixvim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nixvimLib = nixvim.lib.${system};
        nixvim' = nixvim.legacyPackages.${system};
        nvim = nixvim'.makeNixvimWithModule {
          inherit pkgs;
          module = {
            colorschemes.gruvbox.enable = true;

            extraPackages = with pkgs; [
              nixfmt-rfc-style
              stylua
              nodePackages.prettier
              shfmt
              bash
            ];

            plugins = {
              nvim-autopairs = {
                enable = true;
                settings = {
                  checkTs = true;
                };
              };

              web-devicons.enable = true;

              persistence = {
                enable = true;

                settings = {
                  options = [
                    "buffers"
                    "curdir"
                    "tabpages"
                    "winsize"
                  ];
                };
              };

              which-key = {
                enable = true;
              };

              conform-nvim = {
                enable = true;
                settings = {
                  formatters_by_ft = {
                    nix = [ "nixfmt" ];
                    lua = [ "stylua" ];
                    javascript = [ "prettier" ];
                    typescript = [ "prettier" ];
                    javascriptreact = [ "prettier" ];
                    typescriptreact = [ "prettier" ];
                    css = [ "prettier" ];
                    html = [ "prettier" ];
                    markdown = [ "prettier" ];
                    sh = [ "shfmt" ];
                  };
                  formatters = {
                    shfmt = {
                      prepend_args = [
                        "-i"
                        "2"
                        "-ci"
                      ];
                    };
                    stylua = {
                      prepend_args = [
                        "--indent-type"
                        "Spaces"
                        "--indent-width"
                        "2"
                        "--line-endings"
                        "Unix"
                      ];
                    };
                  };
                  format_on_save = {
                    lsp_fallback = true;
                  };
                };
              };

              copilot-chat.enable = true;

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
                  window.mappings = {
                    "<bs>" = "navigate_up";
                    "." = "set_root";
                    "f" = "fuzzy_finder";
                    "/" = "filter_on_submit";
                    "h" = "show_help";
                  };
                };
              };

              bufferline = {
                enable = true;
                settings = {
                  options = {
                    separatorStyle = "thick"; # “slant”, “padded_slant”, “slope”, “padded_slope”, “thick”, “thin”
                    offsets = [
                      {
                        filetype = "neo-tree";
                        text = "Neo-tree";
                        highlight = "Directory";
                        text_align = "left";
                      }
                    ];
                  };
                };
              };

              treesitter = {
                enable = true;
                settings = {
                  ensure_installed = [
                    "bash"
                    "comment"
                    "diff"
                    "git_config"
                    "git_rebase"
                    "gitattributes"
                    "gitcommit"
                    "gitignore"
                    "hcl"
                    "html"
                    "javascript"
                    "json"
                    "json5"
                    "jsonc"
                    "lua"
                    "luadoc"
                    "make"
                    "markdown"
                    "markdown_inline"
                    "nix"
                    "python"
                    "query"
                    "regex"
                    "sql"
                    "terraform"
                    "toml"
                    "vim"
                    "vimdoc"
                    "yaml"
                  ];
                  highlight.enable = true;
                  indent.enable = true;
                };
              };

              lualine = {
                enable = true;
                settings = {
                  options = {
                    theme = "gruvbox";
                    section_separators = {
                      left = "";
                      right = "";
                    };
                  };
                };
              };

              telescope = {
                enable = true;

                extensions = {
                  fzf-native.enable = true;
                  ui-select.enable = true;
                };

                keymaps = {
                  # Quick access (LazyVim style)
                  "<leader><space>" = {
                    action = "find_files";
                    options.desc = "Find Files (Root Dir)";
                  };
                  "<leader>/" = {
                    action = "live_grep";
                    options.desc = "Grep (Root Dir)";
                  };
                  "<leader>," = {
                    action = "buffers";
                    options.desc = "Switch Buffer";
                  };
                  # Search namespace (LazyVim <leader>s)
                  "<leader>sg" = {
                    action = "live_grep";
                    options.desc = "Grep (Root Dir)";
                  };
                  "<leader>sG" = {
                    action = "live_grep";
                    options.desc = "Grep (cwd)";
                  };
                  "<leader>sw" = {
                    action = "grep_string";
                    options.desc = "Word (Root Dir)";
                  };
                  "<leader>sW" = {
                    action = "grep_string";
                    options.desc = "Word (cwd)";
                  };
                  "<leader>sb" = {
                    action = "current_buffer_fuzzy_find";
                    options.desc = "Buffer";
                  };
                  "<leader>sc" = {
                    action = "command_history";
                    options.desc = "Command History";
                  };
                  "<leader>sC" = {
                    action = "commands";
                    options.desc = "Commands";
                  };
                  "<leader>sd" = {
                    action = "diagnostics";
                    options.desc = "Diagnostics";
                  };
                  "<leader>sh" = {
                    action = "help_tags";
                    options.desc = "Help Pages";
                  };
                  "<leader>sk" = {
                    action = "keymaps";
                    options.desc = "Keymaps";
                  };
                  "<leader>sm" = {
                    action = "marks";
                    options.desc = "Marks";
                  };
                  "<leader>sr" = {
                    action = "oldfiles";
                    options.desc = "Recent";
                  };
                  "<leader>sR" = {
                    action = "resume";
                    options.desc = "Resume";
                  };

                  # File namespace (keep for compatibility)
                  "<leader>ff" = {
                    action = "find_files";
                    options.desc = "Find Files (Root Dir)";
                  };
                  "<leader>fF" = {
                    action = "find_files";
                    options.desc = "Find Files (cwd)";
                  };
                  "<leader>fb" = {
                    action = "buffers";
                    options.desc = "Buffers";
                  };
                  "<leader>fr" = {
                    action = "oldfiles";
                    options.desc = "Recent";
                  };
                  "<leader>fR" = {
                    action = "oldfiles";
                    options.desc = "Recent (cwd)";
                  };

                  # Git files
                  "<leader>fg" = {
                    action = "git_files";
                    options.desc = "Find Files (git-files)";
                  };

                  # LSP Symbols (LazyVim <leader>ss and <leader>sS)
                  "<leader>ss" = {
                    action = "lsp_document_symbols";
                    options.desc = "LSP Symbols";
                  };
                  "<leader>sS" = {
                    action = "lsp_workspace_symbols";
                    options.desc = "LSP Workspace Symbols";
                  };
                };
              };
            };

            opts = {
              number = true;
              relativenumber = false;
              shiftwidth = 2;
              tabstop = 2;
              expandtab = true;
            };

            globals.mapleader = " ";

            keymaps = [
              {
                mode = "n";
                key = "<leader>ql";
                action = "<cmd>lua require('persistence').load({ last = true })<cr>";
                options = {
                  silent = true;
                  desc = "Restore last session";
                };
              }
              {
                mode = "n";
                key = "<leader>gc";
                action = "<cmd>CopilotGitMessage<cr>";
                options = {
                  silent = true;
                  desc = "Copilot generate git commit message";
                };
              }
              {
                mode = "n";
                key = "<leader>qd";
                action = "<cmd>lua require('persistence').stop()<cr>";
                options = {
                  silent = true;
                  desc = "Don't save current session";
                };
              }
              {
                mode = "n";
                key = "<Esc>";
                action = "<cmd>nohlsearch<CR>";
                options = {
                  silent = true;
                  desc = "Clear search highlight";
                };
              }
              {
                mode = "n";
                key = "<leader>fe";
                action = ":Neotree toggle reveal_force_cwd<cr>";
                options = {
                  silent = true;
                  desc = "Explorer NeoTree (root dir)";
                };
              }
              {
                mode = "n";
                key = "<leader>fE";
                action = "<cmd>Neotree toggle<CR>";
                options = {
                  silent = true;
                  desc = "Explorer NeoTree (cwd)";
                };
              }
              {
                mode = "n";
                key = "<leader>be";
                action = ":Neotree buffers<CR>";
                options = {
                  silent = true;
                  desc = "Buffer explorer";
                };
              }
              {
                mode = "n";
                key = "<leader>ge";
                action = ":Neotree git_status<CR>";
                options = {
                  silent = true;
                  desc = "Git explorer";
                };
              }
            ];
            extraConfigLua = ''
              vim.api.nvim_create_autocmd("VimEnter", {
                  callback = function()
                    require("persistence").load({ last = true })
                  end,
                })

              vim.api.nvim_create_user_command("CopilotGitMessage", function()
                vim.cmd("normal! GVgg")

                local prompt = [[
                You are an expert at writing Git commits. Your job is to write a short clear commit message that summarizes the changes.

                The commit message should be structured as follows:

                    <type>(<optional scope>): <description>

                    [optional body]

                Rules:

                - Commits MUST be prefixed with a type, which consists of one of the following words:
                  build, chore, ci, docs, feat, fix, perf, refactor, style, test
                - The type feat MUST be used when a commit adds a new feature
                - The type fix MUST be used when a commit represents a bug fix
                - An optional scope MAY be provided after a type
                - The subject line MUST be in imperative mood
                - Try to limit the subject line to 60 characters
                - Lowercase the subject line
                - Do not end the subject line with punctuation

                Commit body rules:

                - Begin one blank line after the subject
                - Use bullet points starting with "- "
                - Capitalize the first letter of each bullet
                - Omit the body if it adds no value
                ]]

                vim.cmd.CopilotChat(prompt)
              end, { desc = "Generate git commit message with Copilot" })
            '';
          };
        };
      in
      {
        packages.default = nvim;
        apps.default = {
          type = "app";
          program = "${nvim}/bin/nvim";
        };
      }
    );
}
