_:

{
  programs.nixvim.plugins.fzf-lua = {
    enable = true;
    keymaps = {
      # Buffers / files
      "<leader>," = {
        action = "buffers";
        settings = {
          sort_mru = true;
          sort_lastused = true;
        };
        options.desc = "Switch Buffer";
      };

      "<leader>fB" = {
        action = "buffers";
        options.desc = "Buffers (all)";
      };

      "<leader>fb" = {
        action = "buffers";
        settings = {
          sort_mru = true;
          sort_lastused = true;
        };
        options.desc = "Buffers";
      };

      "<leader>fg" = {
        action = "git_files";
        options.desc = "Find Files (git-files)";
      };

      "<leader>fr" = {
        action = "oldfiles";
        options.desc = "Recent";
      };

      # Command / history
      "<leader>:" = {
        action = "command_history";
        options.desc = "Command History";
      };

      "<leader>sc" = {
        action = "command_history";
        options.desc = "Command History";
      };

      "<leader>s/" = {
        action = "search_history";
        options.desc = "Search History";
      };

      "<leader>sC" = {
        action = "commands";
        options.desc = "Commands";
      };

      "<leader>sR" = {
        action = "resume";
        options.desc = "Resume";
      };

      # Git
      "<leader>gS" = {
        action = "git_stash";
        options.desc = "Git Stash";
      };

      "<leader>gc" = {
        action = "git_commits";
        options.desc = "Git Commits";
      };

      "<leader>gl" = {
        action = "git_commits";
        options.desc = "Git Commits";
      };

      "<leader>gd" = {
        action = "git_diff";
        options.desc = "Git Diff (hunks)";
      };

      "<leader>gs" = {
        action = "git_status";
        options.desc = "Git Status";
      };

      # Search / info
      "<leader>s\"" = {
        action = "registers";
        options.desc = "Registers";
      };

      "<leader>sH" = {
        action = "highlights";
        options.desc = "Search Highlight Groups";
      };

      "<leader>sM" = {
        action = "man_pages";
        options.desc = "Man Pages";
      };

      "<leader>sa" = {
        action = "autocmds";
        options.desc = "Auto Commands";
      };

      "<leader>sb" = {
        action = "lines";
        options.desc = "Buffer Lines";
      };

      "<leader>sj" = {
        action = "jumps";
        options.desc = "Jumplist";
      };

      "<leader>sk" = {
        action = "keymaps";
        options.desc = "Key Maps";
      };

      "<leader>sl" = {
        action = "loclist";
        options.desc = "Location List";
      };

      "<leader>sm" = {
        action = "marks";
        options.desc = "Jump to Mark";
      };

      "<leader>sq" = {
        action = "quickfix";
        options.desc = "Quickfix List";
      };

      # Diagnostics
      "<leader>sD" = {
        action = "diagnostics_document";
        options.desc = "Buffer Diagnostics";
      };

      "<leader>sd" = {
        action = "diagnostics_workspace";
        options.desc = "Diagnostics";
      };

      "<leader>sh" = {
        action = "help_tags";
        options.desc = "Help Pages";
      };
    };
  };
}
