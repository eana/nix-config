{ pkgs, ... }:

{
  programs.nixvim = {
    autoCmd = [
      {
        event = [
          "BufWritePost"
          "BufEnter"
          "InsertLeave"
        ];
        callback = {
          __raw = ''
            function()
              require('lint').try_lint()
            end
          '';
        };
      }
    ];

    plugins.lint = {
      enable = true;

      linters = {
        jq = {
          cmd = "${pkgs.jq}/bin/jq";
          args = [
            "--exit-status"
            "."
          ];
        };
      };

      lintersByFt = {
        python = [ "ruff" ];

        terraform = [ "tflint" ];
        tf = [ "tflint" ];
        "terraform-vars" = [ "tflint" ];
        hcl = [ "tflint" ];

        nix = [
          "statix"
          "deadnix"
        ];

        yaml = [ "yamllint" ];
        yml = [ "yamllint" ];

        github-actions = [ "actionlint" ];

        markdown = [ "markdownlint" ];

        lua = [ "selene" ];

        json = [ "jq" ];
        jsonc = [ "jq" ];
        json5 = [ "jq" ];

        text = [ ];
        txt = [ ];
      };
    };

    diagnostic.settings = {
      # Enable virtual text for inline diagnostics
      virtual_text = false;

      # Configure signs in the sign column
      signs = {
        text = {
          ERROR = "E";
          WARN = "W";
          INFO = "I";
          HINT = "H";
        };
      };

      # Underline problematic text
      underline = true;

      # Update diagnostics in insert mode
      update_in_insert = false;

      # Sort diagnostics by severity
      severity_sort = true;

      # Floating window configuration
      float = {
        border = "rounded";
        source = "always";
        header = "";
        prefix = "";
      };
    };
  };
}
