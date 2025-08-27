_: {
  programs.nixvim = {
    plugins = {
      ts-autotag.enable = true;
      ts-context-commentstring.enable = true;
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "astro"
            "bash"
            "css"
            "html"
            "javascript"
            "json"
            "jsonc"
            "lua"
            "luadoc"
            "markdown"
            "markdown_inline"
            "regex"
            "tsx"
            "typescript"
            "yaml"
          ];
          highlight = {
            enable = true;
            additional_vim_regex_highlighting = true;
          };
          indent = {
            enable = true;
            disable = [
              "ruby"
            ];
          };
        };
      };
    };

  };
}
