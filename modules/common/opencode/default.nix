{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    ;
  cfg = config.module.opencode;
  custom = config.custom or { };
  tuiTheme = if (custom.theme or "gruvbox") == "gruvbox" then "gruvbox" else "catppuccin";

  pluginConfig = import ./plugins.nix {
    inherit lib pkgs;
    enableSnip = cfg.snip.enable;
    enableCopilotAutoModel = cfg.copilotAutoModel.enable;
    copilotAutoModelAutos = cfg.copilotAutoModel.autos;
  };

  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v6.2.0";
    hash = "sha256-F5LEk0yNWbMpan1vZSFZM76XSpsFGvA7h8q6Idrvenk=";
  };

  superpowersSkillsList = [
    "brainstorming"
    "dispatching-parallel-agents"
    "executing-plans"
    "finishing-a-development-branch"
    "receiving-code-review"
    "requesting-code-review"
    "subagent-driven-development"
    "systematic-debugging"
    "test-driven-development"
    "using-git-worktrees"
    "using-superpowers"
    "verification-before-completion"
    "writing-plans"
    "writing-skills"
  ];

  superpowersSkills = builtins.listToAttrs (
    map (name: {
      name = "superpowers-${name}";
      value = "${superpowersSrc}/skills/${name}";
    }) superpowersSkillsList
  );

  defaultSkills = {
    # keep-sorted start
    flake-parts = ../../../assets/.config/opencode/skills/flake-parts;
    ghq-lookup = ../../../assets/.config/opencode/skills/ghq-lookup;
    git-commit = ../../../assets/.config/opencode/skills/git-commit;
    gitlab-cli-tool = ../../../assets/.config/opencode/skills/gitlab-cli-tool;
    nix-check = ../../../assets/.config/opencode/skills/nix-check;
    nix-coding = ../../../assets/.config/opencode/skills/nix-coding;
    nix-config = ../../../assets/.config/opencode/skills/nix-config;
    skill-creator = ../../../assets/.config/opencode/skills/skill-creator;
    style = ../../../assets/.config/opencode/skills/style;
    # keep-sorted end
  }
  // superpowersSkills;

  baseContext = builtins.readFile ./base-context.md;
in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    home.packages = lib.optionals cfg.snip.enable [ pkgs.snip ];

    xdg.configFile."snip/config.toml" = mkIf cfg.snip.enable {
      source = ../../../assets/.config/snip/config.toml;
    };

    programs.mcp = {
      enable = true;
      servers = import ./mcp.nix { inherit lib pkgs; };
    };

    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      enableMcpIntegration = true;

      settings = {
        autoshare = false;
        autoupdate = false;
        experimental.disable_paste_summary = true;
        share = "disabled";
        lsp = {
          nixd = {
            command = [ (lib.getExe pkgs.nil) ];
            extensions = [ ".nix" ];
          };

          jsonls = {
            command = [
              (lib.getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server")
              "--stdio"
            ];
            extensions = [
              ".json"
              ".jsonc"
            ];
          };

          yamlls = {
            command = [
              (lib.getExe pkgs.yaml-language-server)
              "--stdio"
            ];
            extensions = [
              ".yaml"
              ".yml"
            ];
          };

          gopls = {
            command = [ (lib.getExe pkgs.gopls) ];
            extensions = [
              ".go"
              ".mod"
              ".sum"
            ];
          };

          bashls = {
            command = [
              (lib.getExe pkgs.bash-language-server)
              "start"
            ];
            extensions = [
              ".sh"
              ".bash"
            ];
          };

          biome = {
            command = [
              (lib.getExe pkgs.biome)
              "lsp-proxy"
            ];
            extensions = [
              ".js"
              ".ts"
              ".jsx"
              ".tsx"
            ];
          };
        };
      }
      // import ./permissions.nix { enableSnip = cfg.snip.enable; }
      // {
        inherit (pluginConfig) plugin;
      };

      tui = {
        theme = tuiTheme;
        keybinds = {
          session_export = "none";
          session_share = "none";
          session_unshare = "none";
          terminal_suspend = "none";
          messages_first = "ctrl+home";
          messages_last = "ctrl+end";
        };
      };

      context = baseContext + cfg.extraContext;

      skills = defaultSkills // cfg.extraSkills;
    };
  };
}
