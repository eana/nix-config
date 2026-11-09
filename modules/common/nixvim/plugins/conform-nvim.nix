{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.module.nixvim;
in
{
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      plugins.conform-nvim = {
        enable = true;

        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };

          formatters_by_ft = {
            lua = [ "stylua" ];
            sh = [ "shfmt" ];

            terraform = [ "terraform_fmt" ];
            tf = [ "terraform_fmt" ];
            "terraform-vars" = [ "terraform_fmt" ];

            python = [ "ruff" ];
            nix = [ "nixfmt" ];

            go = [
              "gofmt"
              "goimports"
            ];

            javascript = [ "prettierd" ];
            typescript = [ "prettierd" ];
            json = [ "prettierd" ];
            json5 = [ "prettierd" ];
            jsonc = [ "prettierd" ];
            yaml = [
              "prettierd"
              "yamlfmt"
            ];
            markdown = [ "prettierd" ];
            "markdown.mdx" = [ "prettierd" ];
          };

          formatters = {
            injected.options.ignore_errors = true;

            terraform_fmt.command = lib.getExe pkgs.opentofu;

            shfmt.prepend_args = [
              "-i"
              "2"
              "-ci"
            ];

            stylua.prepend_args = [
              "--indent-type"
              "Spaces"
              "--indent-width"
              "2"
              "--line-endings"
              "Unix"
            ];
          };
        };
      };

      keymaps = [
        {
          mode = [
            "n"
            "v"
          ];
          key = "<leader>cF";
          action = "<cmd>lua require('conform').format({ formatters = { 'injected' } })<CR>";
          options.desc = "Format Injected Langs";
        }
      ];
    };
  };
}
