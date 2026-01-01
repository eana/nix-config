{ pkgs, ... }:

let
  d2-vim = pkgs.vimUtils.buildVimPlugin {
    name = "d2-vim";
    src = pkgs.fetchFromGitHub {
      owner = "terrastruct";
      repo = "d2-vim";
      rev = "cb3eb7fcb1a2d45c4304bf2e91077d787b724a39";
      hash = "sha256-HmDQfOIoSV93wqRe7O4FPuHEmAxwoP1+Ut+sKhB62jA=";
    };
  };

  d2-grammar-src = pkgs.fetchFromGitHub {
    owner = "ravsii";
    repo = "tree-sitter-d2";
    rev = "ffb66ce4c801a1e37ed145ebd5eca1ea8865e00f";
    hash = "sha256-E8NcTrPsann8NMB8yLTbJghyf19chhpnKFlthuZ4l14=";
  };

  d2-queries = pkgs.vimUtils.buildVimPlugin {
    name = "d2-queries";
    src = d2-grammar-src;
    postInstall = ''
      mkdir -p $out/queries/d2
      cp queries/highlights.scm $out/queries/d2/
    '';
  };
in
{
  programs.nixvim = {
    extraPlugins = [
      d2-vim
      d2-queries
    ];

    filetype.extension.d2 = "d2";
  };
}
