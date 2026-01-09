{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [
      # ==================== Tabs ====================
      {
        key = "<leader>tc";
        mode = "n";
        action = "<cmd>tabnew<CR>";
        options.desc = "New tab";
      }
      {
        key = "<leader>tn";
        mode = "n";
        action = "<cmd>tabnext<CR>";
        options.desc = "Next tab";
      }
      {
        key = "<leader>tp";
        mode = "n";
        action = "<cmd>tabprevious<CR>";
        options.desc = "Previous tab";
      }
      {
        key = "<leader>td";
        mode = "n";
        action = "<cmd>tabclose<CR>";
        options.desc = "Close tab";
      }

      # ==================== Buffers ====================
      {
        key = "<leader>,";
        mode = "n";
        action = "<cmd>lua Snacks.picker.buffers()<cr>";
        options.desc = "Switch Buffer";
      }
      {
        key = "<leader>bb";
        mode = "n";
        action = "<cmd>e #<cr>";
        options.desc = "Switch to other buffer";
      }
      {
        key = "<leader>be";
        mode = "n";
        action = "<cmd>lua Snacks.picker.buffers()<cr>";
        options.desc = "Buffer Explorer";
      }
      {
        key = "<leader>bd";
        mode = "n";
        action = "<cmd>lua Snacks.bufdelete()<cr>";
        options.desc = "Delete buffer";
      }
      {
        key = "<leader>bl";
        mode = "n";
        action = "<cmd>lua Snacks.bufdelete.left()<cr>";
        options.desc = "Close buffers to the left";
      }
      {
        key = "<leader>br";
        mode = "n";
        action = "<cmd>lua Snacks.bufdelete.right()<cr>";
        options.desc = "Close buffers to the right";
      }
      {
        key = "<leader>bo";
        mode = "n";
        action = "<cmd>lua Snacks.bufdelete.other()<cr>";
        options.desc = "Close other buffers";
      }

      # ==================== File & Project Explorer ====================
      {
        key = "<leader>fn";
        mode = "n";
        action = "<Cmd>enew<CR>";
        options.desc = "New file";
      }
      {
        key = "<leader>fe";
        mode = "n";
        action = "<cmd>lua Snacks.explorer.open()<cr>";
        options.desc = "Project explorer (root dir)";
      }
      {
        key = "<leader>fE";
        mode = "n";
        action = "<cmd>lua Snacks.explorer.open({ cwd = vim.fn.getcwd() })<cr>";
        options.desc = "Explorer (current working dir)";
      }
      {
        key = "<leader>ge";
        mode = "n";
        action = "<cmd>lua Snacks.picker.git_status()<cr>";
        options.desc = "Git status explorer";
      }

      # ==================== Search / Picker ====================
      # Quick Access
      {
        key = "<leader><space>";
        mode = "n";
        action = "<cmd>lua Snacks.picker.smart()<cr>";
        options.desc = "Find Files (Smart)";
      }
      {
        key = "<leader>,";
        mode = "n";
        action = "<cmd>lua Snacks.picker.buffers()<cr>";
        options.desc = "Switch Buffer";
      }
      {
        key = "<leader>/";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep()<cr>";
        options.desc = "Grep (Root Dir)";
      }
      {
        key = "<leader>:";
        mode = "n";
        action = "<cmd>lua Snacks.picker.command_history()<cr>";
        options.desc = "Command History";
      }

      # File Namespace (f)
      {
        key = "<leader>ff";
        mode = "n";
        action = "<cmd>lua Snacks.picker.files()<cr>";
        options.desc = "Find Files (Root)";
      }
      {
        key = "<leader>fF";
        mode = "n";
        action = "<cmd>lua Snacks.picker.files({ cwd = vim.fn.getcwd() })<cr>";
        options.desc = "Find Files (CWD)";
      }
      {
        key = "<leader>fg";
        mode = "n";
        action = "<cmd>lua Snacks.picker.git_files()<cr>";
        options.desc = "Find Git Files";
      }
      {
        key = "<leader>fr";
        mode = "n";
        action = "<cmd>lua Snacks.picker.recent()<cr>";
        options.desc = "Recent";
      }
      {
        key = "<leader>fR";
        mode = "n";
        action = "<cmd>lua Snacks.picker.recent({ filter = { cwd = true }})<cr>";
        options.desc = "Recent (cwd)";
      }

      # Search Namespace (s)
      {
        key = "<leader>sa";
        mode = "n";
        action = "<cmd>lua Snacks.picker.autocmds()<cr>";
        options.desc = "Auto Commands";
      }
      {
        key = "<leader>sb";
        mode = "n";
        action = "<cmd>lua Snacks.picker.lines()<cr>";
        options.desc = "Buffer Lines (Fuzzy)";
      }
      {
        key = "<leader>sc";
        mode = "n";
        action = "<cmd>lua Snacks.picker.command_history()<cr>";
        options.desc = "Command History";
      }
      {
        key = "<leader>sC";
        mode = "n";
        action = "<cmd>lua Snacks.picker.commands()<cr>";
        options.desc = "Commands";
      }
      {
        key = "<leader>sd";
        mode = "n";
        action = "<cmd>lua Snacks.picker.diagnostics()<cr>";
        options.desc = "Diagnostics (Workspace)";
      }
      {
        key = "<leader>sD";
        mode = "n";
        action = "<cmd>lua Snacks.picker.diagnostics({ filter = { bufnr = 0 }})<cr>";
        options.desc = "Diagnostics (Buffer)";
      }
      {
        key = "<leader>sg";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep()<cr>";
        options.desc = "Grep (Root)";
      }
      {
        key = "<leader>sG";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep({ cwd = vim.fn.getcwd() })<cr>";
        options.desc = "Grep (CWD)";
      }
      {
        key = "<leader>sh";
        mode = "n";
        action = "<cmd>lua Snacks.picker.help()<cr>";
        options.desc = "Help Pages";
      }
      {
        key = "<leader>sH";
        mode = "n";
        action = "<cmd>lua Snacks.picker.highlights()<cr>";
        options.desc = "Search Highlights";
      }
      {
        key = "<leader>sj";
        mode = "n";
        action = "<cmd>lua Snacks.picker.jumps()<cr>";
        options.desc = "Jumplist";
      }
      {
        key = "<leader>sk";
        mode = "n";
        action = "<cmd>lua Snacks.picker.keymaps()<cr>";
        options.desc = "Keymaps";
      }
      {
        key = "<leader>sl";
        mode = "n";
        action = "<cmd>lua Snacks.picker.loclist()<cr>";
        options.desc = "Location List";
      }
      {
        key = "<leader>sm";
        mode = "n";
        action = "<cmd>lua Snacks.picker.marks()<cr>";
        options.desc = "Jump to Mark";
      }
      {
        key = "<leader>sM";
        mode = "n";
        action = "<cmd>lua Snacks.picker.man()<cr>";
        options.desc = "Man Pages";
      }
      {
        key = "<leader>sq";
        mode = "n";
        action = "<cmd>lua Snacks.picker.qflist()<cr>";
        options.desc = "Quickfix List";
      }
      {
        key = "<leader>ss";
        mode = "n";
        action = "<cmd>lua Snacks.picker.lsp_symbols()<cr>";
        options.desc = "LSP Symbols (Document)";
      }
      {
        key = "<leader>sS";
        mode = "n";
        action = "<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>";
        options.desc = "LSP Symbols (Workspace)";
      }
      {
        key = "<leader>sw";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep_word()<cr>";
        options.desc = "Word (Root Dir)";
      }
      {
        key = "<leader>sW";
        mode = "n";
        action = "<cmd>lua Snacks.picker.grep_word({ cwd = vim.fn.getcwd() })<cr>";
        options.desc = "Word (CWD)";
      }
      {
        key = "<leader>s/";
        mode = "n";
        action = "<cmd>lua Snacks.picker.search_history()<cr>";
        options.desc = "Search History";
      }
      {
        key = "<leader>s\"";
        mode = "n";
        action = "<cmd>lua Snacks.picker.registers()<cr>";
        options.desc = "Registers";
      }
      {
        mode = [
          "n"
          "x"
        ];
        key = "<leader>sr";
        action.__raw = ''
          function()
            local grug = require("grug-far")
            local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
            grug.open({
              transient = true,
              prefills = {
                filesFilter = ext and ext ~= "" and "*." .. ext or nil,
              },
            })
          end
        '';
        options.desc = "Search and Replace";
      }

      # ==================== Git — Diffview ====================
      {
        key = "<leader>gd";
        mode = "n";
        action = "<cmd>DiffviewOpen<CR>";
        options.desc = "Repo diff";
      }
      {
        key = "<leader>gc";
        mode = "n";
        action = "<cmd>DiffviewClose<CR>";
        options.desc = "Close diffview";
      }
      {
        key = "<leader>gh";
        mode = "n";
        action = "<cmd>DiffviewFileHistory %<CR>";
        options.desc = "File history";
      }
      {
        key = "<leader>gH";
        mode = "n";
        action = "<cmd>DiffviewFileHistory<CR>";
        options.desc = "Repo history";
      }

      # ==================== Gitsigns ====================
      {
        key = "]H";
        mode = "n";
        action = "<cmd>lua require('gitsigns').nav_hunk('last')<CR>";
        options.desc = "Last Hunk";
      }
      {
        key = "[H";
        mode = "n";
        action = "<cmd>lua require('gitsigns').nav_hunk('first')<CR>";
        options.desc = "First Hunk";
      }
      {
        key = "<leader>ghs";
        mode = [
          "n"
          "x"
        ];
        action = "<cmd>Gitsigns stage_hunk<CR>";
        options.desc = "Stage Hunk";
      }
      {
        key = "<leader>ghr";
        mode = [
          "n"
          "x"
        ];
        action = "<cmd>Gitsigns reset_hunk<CR>";
        options.desc = "Reset Hunk";
      }
      {
        key = "<leader>ghS";
        mode = "n";
        action = "<cmd>lua require('gitsigns').stage_buffer()<CR>";
        options.desc = "Stage Buffer";
      }
      {
        key = "<leader>ghu";
        mode = "n";
        action = "<cmd>lua require('gitsigns').undo_stage_hunk()<CR>";
        options.desc = "Undo Stage Hunk";
      }
      {
        key = "<leader>ghR";
        mode = "n";
        action = "<cmd>lua require('gitsigns').reset_buffer()<CR>";
        options.desc = "Reset Buffer";
      }
      {
        key = "<leader>ghp";
        mode = "n";
        action = "<cmd>lua require('gitsigns').preview_hunk_inline()<CR>";
        options.desc = "Preview Hunk Inline";
      }
      {
        key = "<leader>ghb";
        mode = "n";
        action = "<cmd>lua require('gitsigns').blame_line({ full = true })<CR>";
        options.desc = "Blame Line";
      }
      {
        key = "<leader>ghB";
        mode = "n";
        action = "<cmd>lua require('gitsigns').blame()<CR>";
        options.desc = "Blame Buffer";
      }
      {
        key = "<leader>ghd";
        mode = "n";
        action = "<cmd>lua require('gitsigns').diffthis()<CR>";
        options.desc = "Diff This";
      }
      {
        key = "<leader>ghD";
        mode = "n";
        action = "<cmd>lua require('gitsigns').diffthis('~')<CR>";
        options.desc = "Diff This ~";
      }
      {
        key = "ih";
        mode = [
          "o"
          "x"
        ];
        action = ":<C-U>Gitsigns select_hunk<CR>";
        options.desc = "GitSigns Select Hunk";
      }
      {
        key = "<leader>gB";
        mode = [
          "n"
          "v"
        ];
        action = "<cmd>lua Snacks.gitbrowse()<CR>";
        options.desc = "Browse repo";
      }

      # ==================== Session & History ====================
      {
        key = "<leader>qs";
        mode = "n";
        action = "<cmd>lua require('persistence').load()<CR>";
        options.desc = "Restore session for current directory";
      }
      {
        key = "<leader>qS";
        mode = "n";
        action = "<cmd>lua require('persistence').select()<CR>";
        options.desc = "Select session to load";
      }
      {
        key = "<leader>ql";
        mode = "n";
        action = "<cmd>lua require('persistence').load({ last = true })<CR>";
        options.desc = "Restore last session";
      }
      {
        key = "<leader>qd";
        mode = "n";
        action = "<cmd>lua require('persistence').stop()<CR>";
        options.desc = "Disable session saving";
      }
      {
        key = "<leader>Tu";
        mode = "n";
        action = "<cmd>UndotreeToggle<CR>";
        options.desc = "Undo tree";
      }

      # ==================== Todo Comments / Diagnostics ====================
      {
        key = "<leader>xt";
        mode = "n";
        action = "<cmd>TodoQuickFix<CR>";
        options.desc = "Todo list";
      }
      {
        key = "<leader>sd";
        mode = "n";
        action = "<cmd>lua Snacks.picker.diagnostics()<cr>";
        options.desc = "Diagnostics (Workspace)";
      }
      {
        key = "<leader>sD";
        mode = "n";
        action = "<cmd>lua Snacks.picker.diagnostics({ filter = { bufnr = 0 }})<cr>";
        options.desc = "Diagnostics (Buffer)";
      }

      # ==================== Editing / Remove Frustrations ====================
      {
        key = "C";
        mode = "n";
        action = "\"_C";
        options = {
          silent = true;
          noremap = true;
          desc = "Change to end without yanking";
        };
      }
      {
        key = "D";
        mode = "n";
        action = "\"_D";
        options = {
          silent = true;
          noremap = true;
          desc = "Delete to end without yanking";
        };
      }
      {
        key = "d";
        mode = "n";
        action = "\"_d";
        options = {
          silent = true;
          noremap = true;
          desc = "Delete without yanking";
        };
      }
      {
        key = "dd";
        mode = "n";
        action = "\"_dd";
        options = {
          silent = true;
          noremap = true;
          desc = "Delete line without yanking";
        };
      }
      {
        key = "x";
        mode = "n";
        action = "\"_x";
        options = {
          silent = true;
          noremap = true;
          desc = "Delete char without yanking";
        };
      }
      {
        key = "c";
        mode = "n";
        action = "\"_c";
        options = {
          silent = true;
          noremap = true;
          desc = "Change without yanking";
        };
      }
      {
        key = "<Esc>";
        mode = "n";
        action = "<cmd>nohlsearch<CR>";
        options.desc = "Clear search highlight";
      }
      {
        key = "<Esc><Esc>";
        mode = "t";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }
      {
        key = "<F5>";
        mode = "n";
        action = ":%s/\\s\\+$//e<CR>";
        options = {
          noremap = true;
          silent = true;
          desc = "Remove all trailing whitespace";
        };
      }
      {
        key = "<C-S-Up>";
        mode = [
          "n"
          "v"
        ];
        action = ":m -2<CR>";
        options.desc = "Move the current line up";
      }
      {
        key = "<C-S-Down>";
        mode = [
          "n"
          "v"
        ];
        action = ":m +1<CR>";
        options.desc = "Move the current line down";
      }
      {
        key = "<C-S-Up>";
        mode = "v";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move the selected lines up";
      }
      {
        key = "<C-S-Down>";
        mode = "v";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move the selected lines down";
      }
      {
        key = "<";
        mode = "v";
        action = "<gv";
        options.desc = "Indent left and reselect";
      }
      {
        key = ">";
        mode = "v";
        action = ">gv";
        options.desc = "Indent right and reselect";
      }

      # ==================== Window Resizing ====================
      {
        key = "<C-Up>";
        mode = "n";
        action = "<Cmd>resize -1<CR>";
        options = {
          noremap = true;
          silent = true;
          desc = "Increase Message Window Height";
        };
      }
      {
        key = "<C-Down>";
        mode = "n";
        action = "<Cmd>resize +1<CR>";
        options = {
          noremap = true;
          silent = true;
          desc = "Decrease Message Window Height";
        };
      }

      # ==================== Core Diagnostics ====================
      {
        mode = "n";
        key = "[d";
        action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
        options.desc = "Go to previous diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
        options.desc = "Go to next diagnostic";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = "<cmd>lua vim.diagnostic.open_float()<cr>";
        options.desc = "Line Diagnostics";
      }
      {
        mode = "n";
        key = "<leader>cl";
        action = "<cmd>lua vim.diagnostic.setloclist()<cr>";
        options.desc = "Linter Quickfix List";
      }
      {
        mode = "n";
        key = "<leader>cv";
        action.__raw = ''
          function()
            local virtual_text_enabled = vim.diagnostic.config().virtual_text
            vim.diagnostic.config({ virtual_text = not virtual_text_enabled })
            print("Virtual Text " .. (virtual_text_enabled and "Off" or "On"))
          end
        '';
        options = {
          desc = "Toggle Diagnostic Virtual Text";
          silent = true;
        };
      }
    ];
  };
}
