{ pkgs }:
# Nushell tree-sitter queries and Topiary language config for nushell formatting.
# Pinned to a specific commit for reproducibility.
pkgs.fetchFromGitHub {
  owner = "blindFS";
  repo = "topiary-nushell";
  rev = "6e2f9b339a664a46e4015fa5d79e537807fefa39";
  hash = "sha256-fTfxSnVI7TY6vQhD+GimPBRJ4K0SyyVtoLcLGH3xIPc=";
}
