{ pkgs }:
# Nushell tree-sitter queries and Topiary language config for nushell formatting.
# Pinned to a specific commit for reproducibility.
pkgs.fetchFromGitHub {
  owner = "blindFS";
  repo = "topiary-nushell";
  rev = "b187defff76caaea7c95614047c1779a675df0f6";
  hash = "sha256-a9yWF75XPll2EYGE0LEDByFCcLUC+DmgfRToqTUNi60=";
}
