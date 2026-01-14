_:

{
  programs.nixvim = {
    plugins.copilot-lua = {
      enable = true;
      settings = {
        server_opts_overrides = {
          settings = {
            telemetry.telemetryLevel = "off";
          };
        };
        suggestion.enabled = false;
        panel.enabled = false;
        filetypes = {
          "*" = true;
        };
      };
    };

    plugins.copilot-chat = {
      enable = true;
      settings = {
        mappings = {
          close = {
            insert = "<C-c>";
            normal = "q";
          };
          complete = {
            insert = "<Tab>";
          };
        };
        window.layout = "vertical";
      };
    };

    extraConfigLua = ''
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
    '';
  };
}
