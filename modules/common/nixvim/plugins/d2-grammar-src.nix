{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "ravsii";
  repo = "tree-sitter-d2";
  rev = "7bba28221d8c466d28b725124494bf89219326fd";
  hash = "sha256-5OBG7FPZANtf+HoVZv9+sCC58qN4SMmHl5vxsHvj13g=";
}
