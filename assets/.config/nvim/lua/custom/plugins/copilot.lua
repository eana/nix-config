return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
  },
  {
    "github/copilot.vim",
    config = function()
      -- disable tab completion for github copilot
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""
      -- set copilot completion keybinding to <C-f>
      vim.keymap.set("i", "<C-f>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        nowait = true,
        replace_keycodes = false,
        silent = true,
      })

      local copilot_enabled = true
      vim.api.nvim_create_user_command("CopilotToggle", function()
        if copilot_enabled then
          vim.cmd("Copilot disable")
          print("Copilot disabled")
        else
          vim.cmd("Copilot enable")
          print("Copilot enabled")
        end
        copilot_enabled = not copilot_enabled
      end, {})

      vim.api.nvim_create_user_command("CopilotGitMessage", function()
        vim.cmd("normal! GVgg")
        vim.cmd("CopilotChat Please write a conventional git commit message for these changes")
      end, {})

      vim.keymap.set("n", "<leader>ct", ":CopilotToggle<CR>", { desc = "Toggle Copilot" })
      vim.keymap.set("n", "<leader>cg", ":CopilotGitMessage<CR>", { desc = "Copilot generate git commit message" })
    end,
  },
}
