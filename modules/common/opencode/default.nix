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

  catalog = import ./skills-catalog.nix;

  pluginConfig = import ./plugins.nix {
    inherit lib pkgs;
    enableSnip = cfg.snip.enable;
    enableCopilotAutoModel = cfg.copilotAutoModel.enable;
    copilotAutoModelAutos = cfg.copilotAutoModel.autos;
  };

  skillsConfig = import ./skills.nix {
    inherit lib pkgs;
    enabledSkills = cfg.skills.enabled;
  };

  baseContext = builtins.readFile ./base-context.md;
in
{
  imports = [ ./interface.nix ];

  config = mkIf cfg.enable {
    # Opt-out baseline: local + superpowers skills are on unless a host
    # explicitly removes them (via mkForce). Linkedin and social skills stay
    # opt-in (see playwright.enable and skills.enabled = [ "social" ... ]).
    module.opencode.skills.enabled = catalog.local ++ [ "superpowers" ];

    home.packages = lib.optionals cfg.snip.enable [ pkgs.snip ];

    xdg.configFile."snip/config.toml" = mkIf cfg.snip.enable {
      source = ../../../assets/.config/snip/config.toml;
    };

    programs.mcp = {
      enable = true;
      servers = import ./mcp.nix {
        inherit lib pkgs;
        enablePlaywright = cfg.playwright.enable;
        playwrightUserDataDir = "${config.home.homeDirectory}/.cache/playwright-mcp";
      };
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
        lsp = import ./lsp.nix { inherit lib pkgs; };
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

      skills =
        skillsConfig
        // lib.optionalAttrs cfg.playwright.enable {
          linkedin-profile-editor = ../../../assets/.config/opencode/skills/linkedin-profile-editor;
        }
        // cfg.extraSkills;
    };
  };
}
