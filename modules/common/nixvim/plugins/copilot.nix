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
        model = "auto";
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
      ## Conform file

      At the start of any commit workflow, check for `.conform.yml` or `.conform.yaml` in the repo root. If found, read it and extract the allowed types and scopes defined there - those replace the hardcoded defaults below. Obey whatever the conform file specifies; it is the source of truth for this repo.

      ## Commit message structure

      ```
      <type>(<optional scope>): <description>

      [optional body]

      [optional footer]
      ```

      ## Types

      Default (used when no `.conform.yml` is present):

      `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`

      ## Subject line rules

      - Type and description are required; scope is optional
      - Description must immediately follow the type/scope prefix
      - Write in imperative mood: `add`, `fix`, `update`, `remove`, `rename`
      - Limit to 60 characters
      - Lowercase the entire subject line
      - Do not end with punctuation
      - ASCII only: no emdashes, emojis, or other non-ASCII characters. Use hyphens (-) instead of emdashes

      ## Scope rules

      - Use one of the area categories defined in `.conform.yaml`: `module`, `deps`, `devshell`, `configurations`, `home`, `hosts`, `secrets`, `assets`, `flake`
      - `module` covers changes in `modules/` directory
      - `deps` covers flake.lock and dependency updates
      - `devshell` covers dev environment and dev workflows
      - `configurations` covers per-host flake module configurations
      - `home` covers home-manager user configurations
      - `hosts` covers NixOS/darwin system configurations
      - `secrets` covers secret management
      - `assets` covers non-config assets
      - `flake` covers flake.nix structural changes
      - Omit scope when a change is genuinely cross-cutting (touches three or more unrelated areas)
      - The conform hook allows substring matching, so `home` accepts `home-manager`, `homebrew`, etc. - prefer canonical names when possible

      ## Body rules

      - Leave one blank line between subject and body
      - Use bullet points starting with `- `
      - Capitalise the first letter of each bullet point
      - Write each bullet in imperative mood
      - Keep bullet points short and clear
      - ASCII only: no emdashes, emojis, or other non-ASCII characters. Use hyphens (-) instead of emdashes
      - Omit the body entirely if it adds no useful detail beyond the subject
      ]]

        vim.cmd.CopilotChat(prompt)
      end, {})
    '';
  };
}
