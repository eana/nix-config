{ pkgs, ... }:

let
  d2-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "d2-vim";
    version = "0-unstable-2025-08-19";
    src = pkgs.fetchFromGitHub {
      owner = "terrastruct";
      repo = "d2-vim";
      rev = "a950f1a276506ac4bbc274dd65ba98b15a1d490d";
      hash = "sha256-iAPP/Ohf3Aw8I4WmNvTtyMja48stsG4pzp8cZjcDjRg=";
    };
  };

  d2-grammar-src = import ./d2-grammar-src.nix { inherit pkgs; };

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
