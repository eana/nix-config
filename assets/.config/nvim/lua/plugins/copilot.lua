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
        local prompt = [[
You are an expert at writing Git commits. Your job is to write a short clear commit message that summarizes the changes

The commit message should be structured as follows:

    <type>(<optional scope>): <description>

    [optional body]

Rules:

- Commits MUST be prefixed with a type, which consists of one of the following words: build, chore, ci, docs, feat, fix, perf, refactor, style, test
- The type feat MUST be used when a commit adds a new feature
- The type fix MUST be used when a commit represents a bug fix
- An optional scope MAY be provided after a type. A scope is a phrase describing a section of the codebase enclosed in parenthesis, e.g., fix(parser)
- A description MUST immediately follow the type/scope prefix. The description is a short summary of the code changes
- The subject line MUST be in imperative mood (e.g., add, fix, update)
- Try to limit the subject line to 60 characters
- Lowercase the subject line
- Do not end the subject line with punctuation

Commit body:

- The body MUST begin one blank line after the subject line
- If a body is included, it MUST use bullet points starting with a hyphen and space
- The first letter of each bullet point MUST be capitalized
- Each bullet point MUST be written in imperative mood
- Keep bullet points short and clear
- Omit the body entirely if it does not add useful detail beyond the subject
]]

        vim.cmd.CopilotChat(prompt)
      end, {})

      vim.keymap.set("n", "<leader>ct", ":CopilotToggle<CR>", { desc = "Toggle Copilot" })
      vim.keymap.set("n", "<leader>cg", ":CopilotGitMessage<CR>", { desc = "Copilot generate git commit message" })
    end,
  },
}
