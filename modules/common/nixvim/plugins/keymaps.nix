{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    keymaps = [

      # ========================================================================
      # TABS
      # ========================================================================
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

      # ========================================================================
      # BUFFERS
      # ========================================================================
      {
        key = "<leader>bb";
        mode = "n";
        action = "<cmd>e #<cr>";
        options.desc = "Switch to other buffer";
      }
      {
        key = "<leader>bd";
        mode = "n";
        action = "<cmd>bdelete<cr>";
        options.desc = "Delete buffer";
      }
      {
        key = "<leader>bl";
        mode = "n";
        action = "<cmd>BufferLineCloseLeft<cr>";
        options.desc = "Close buffers to the left";
      }
      {
        key = "<leader>br";
        mode = "n";
        action = "<cmd>BufferLineCloseRight<cr>";
        options.desc = "Close buffers to the right";
      }
      {
        key = "<leader>bo";
        mode = "n";
        action = "<cmd>BufferLineCloseOthers<cr>";
        options.desc = "Close other buffers";
      }

      # ========================================================================
      # FILE & PROJECT EXPLORERS (NEO-TREE)
      # ========================================================================
      {
        key = "<leader>fe";
        mode = "n";
        action = ":Neotree toggle reveal_force_cwd<cr>";
        options.desc = "Project explorer (root dir)";
      }
      {
        key = "<leader>fE";
        mode = "n";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Explorer (current working dir)";
      }
      {
        key = "<leader>be";
        mode = "n";
        action = ":Neotree buffers<CR>";
        options.desc = "Buffer explorer";
      }
      {
        key = "<leader>ge";
        mode = "n";
        action = ":Neotree git_status<CR>";
        options.desc = "Git status explorer";
      }

      # ========================================================================
      # GIT — DIFFVIEW
      # ========================================================================
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

      # ========================================================================
      # GIT — HUNKS (GITSIGNS)
      # ========================================================================
      {
        key = "<leader>gs";
        mode = "n";
        action = "<cmd>Gitsigns stage_hunk<CR>";
        options.desc = "Stage hunk";
      }
      {
        key = "<leader>gs";
        mode = "v";
        action = ":Gitsigns stage_hunk<CR>";
        options.desc = "Stage hunk (visual)";
      }
      {
        key = "<leader>gr";
        mode = "n";
        action = "<cmd>Gitsigns reset_hunk<CR>";
        options.desc = "Reset hunk";
      }
      {
        key = "<leader>gr";
        mode = "v";
        action = ":Gitsigns reset_hunk<CR>";
        options.desc = "Reset hunk (visual)";
      }
      {
        key = "<leader>gS";
        mode = "n";
        action = "<cmd>Gitsigns stage_buffer<CR>";
        options.desc = "Stage buffer";
      }
      {
        key = "<leader>gu";
        mode = "n";
        action = "<cmd>Gitsigns undo_stage_hunk<CR>";
        options.desc = "Undo stage";
      }
      {
        key = "<leader>gR";
        mode = "n";
        action = "<cmd>Gitsigns reset_buffer<CR>";
        options.desc = "Reset buffer";
      }
      {
        key = "<leader>gp";
        mode = "n";
        action = "<cmd>Gitsigns preview_hunk<CR>";
        options.desc = "Preview hunk";
      }
      {
        key = "<leader>gb";
        mode = "n";
        action = "<cmd>Gitsigns blame_line<CR>";
        options.desc = "Blame line";
      }
      {
        key = "<leader>gf";
        mode = "n";
        action = "<cmd>Gitsigns diffthis<CR>";
        options.desc = "Diff file";
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

      # ========================================================================
      # SESSION & HISTORY
      # ========================================================================
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

      # ========================================================================
      # TODO COMMENTS
      # ========================================================================
      {
        key = "<leader>xt";
        mode = "n";
        action = "<cmd>TodoQuickFix<CR>";
        options.desc = "Todo list";
      }

      # ========================================================================
      # REMOVE FRUSTRATIONS
      # ========================================================================
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
    ];
  };
}
