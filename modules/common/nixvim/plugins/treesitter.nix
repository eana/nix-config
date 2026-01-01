{ pkgs, ... }:

let
  d2-grammar-src = pkgs.fetchFromGitHub {
    owner = "ravsii";
    repo = "tree-sitter-d2";
    rev = "ffb66ce4c801a1e37ed145ebd5eca1ea8865e00f";
    hash = "sha256-E8NcTrPsann8NMB8yLTbJghyf19chhpnKFlthuZ4l14=";
  };

  d2-grammar = pkgs.tree-sitter.buildGrammar {
    language = "d2";
    version = "0.0.1";
    src = d2-grammar-src;
  };
in
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;

      grammarPackages =
        (with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
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
        ])
        ++ [ d2-grammar ];

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
