{ pkgs, ... }:

let
  d2-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "d2-vim";
    version = "0-unstable-2025-08-19";
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
    rev = "200434618a6bede20ebd4982aa4d4f1edeb0b5c1";
    hash = "sha256-xN6yb7amTu61E8dFHB5Vrv52FOZUKOh3u5zfOIao7rQ=";
  };

  d2-queries = pkgs.vimUtils.buildVimPlugin {
    pname = "d2-queries";
    version = "0-unstable-2026-04-10";
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
