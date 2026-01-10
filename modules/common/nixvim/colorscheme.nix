_:

{
  programs.nixvim = {
    colorschemes = {
      gruvbox-material = {
        enable = true;
        settings = {
          enable_bold = 1;
          enable_italic = 1;
          foreground = "material";
          spell_foreground = "colored";
          material_better_performance = 1;
          material_ui_contrast = "high";
        };
      };

      catppuccin = {
        enable = false;
        settings = {
          background = {
            light = "macchiato";
            dark = "mocha";
          };
          custom_highlights = ''
            function(highlights)
              return {
              CursorLineNr = { fg = highlights.peach, style = {} },
              NavicText = { fg = highlights.text },
              }
            end
          '';
          flavour = "macchiato"; # "latte", "mocha", "frappe", "macchiato" or raw lua code
          no_bold = false;
          no_italic = false;
          no_underline = false;
          transparent_background = false;
          integrations = {
            blink-cmp = true;
            gitsigns = true;
            indent_blankline.enabled = true;
            mini = {
              enabled = true;
              indentscope_color = "rosewater";
            };
            native_lsp = {
              enabled = true;
              inlay_hints = {
                background = true;
              };
              virtual_text = {
                errors = [ "italic" ];
                hints = [ "italic" ];
                information = [ "italic" ];
                warnings = [ "italic" ];
                ok = [ "italic" ];
              };
              underlines = {
                errors = [ "underline" ];
                hints = [ "underline" ];
                information = [ "underline" ];
                warnings = [ "underline" ];
              };
            };
            treesitter = true;
            snacks = true;
            which_key = true;
          };
        };
      };
    };

    extraConfigLua = ''
      -- vim.cmd("colorscheme catppuccin")
      vim.cmd("colorscheme gruvbox-material")

      vim.api.nvim_create_user_command("ToggleTheme", function()
        if vim.opt.background:get() == "dark" then
          vim.opt.background = "light"
        else
          vim.opt.background = "dark"
        end
      end, {})
    '';

    keymaps = [
      {
        mode = "n";
        key = "<Leader>tt";
        action = "<cmd>ToggleTheme<CR>";
        options.desc = "Toggle between dark and light themes";
      }
    ];
  };
}
