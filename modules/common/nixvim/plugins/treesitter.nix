{ pkgs, ... }:

{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        # Shell and scripting
        bash
        make
        ssh_config

        # Version control and git
        diff
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore

        # Programming languages
        go
        gomod
        gowork
        lua
        luadoc
        python
        javascript

        # Configuration and data files
        hcl
        helm
        hjson
        ini
        jq
        json
        json5
        jsonc
        nix
        sql
        terraform
        toml
        yaml

        # Markup and documentation
        markdown
        markdown_inline
        vimdoc

        # Editor and query languages
        vim
        query
        regex

        # Comments
        comment
      ];

      settings = {
        highlight.enable = true;
        indent.enable = false;
        auto_install = false;
        ensure_installed = [ ];
      };

      nixGrammars = true;
    };
    hmts.enable = true;
  };
}
