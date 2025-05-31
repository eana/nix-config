return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot", -- Optional lazy-loading
    config = function()
      require("copilot").setup({
        -- You can add your Copilot config options here
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
        vim.cmd("CopilotChat Please write a git commit message for these changes")
      end, {})

      vim.keymap.set("n", "<leader>ct", ":CopilotToggle<CR>", { desc = "Toggle Copilot" })
      vim.keymap.set("n", "<leader>cg", ":CopilotGitMessage<CR>", { desc = "Copilot generate git commit message" })
    end,
  },
}
