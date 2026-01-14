_:

{
  programs.nixvim.plugins = {
    # --- Completion & Snippets ---
    blink-copilot.enable = true;
    blink-cmp = {
      enable = true;
      settings = {
        # Copilot integration
        sources = {
          providers = {
            copilot = {
              async = true;
              module = "blink-copilot";
              name = "copilot";
              score_offset = 100;
              opts = {
                max_completions = 2;
                max_attempts = 4;
                kind = "Copilot";
                debounce = 300;
                auto_refresh = {
                  backward = false;
                  forward = false;
                };
              };
            };
          };
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
            "copilot"
          ];
        };
        keymap = {
          preset = "enter";
          "<C-f>" = [
            "accept"
            "fallback"
          ];
        };
        appearance.nerd_font_variant = "mono";
        cmdline.sources = [ "cmdline" ];
        completion = {
          list.selection = {
            preselect = true;
            auto_insert = false;
          };
          menu = {
            auto_show = true;
            border = "rounded";
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          ghost_text.enabled = false;
        };
      };
    };
  };
}
