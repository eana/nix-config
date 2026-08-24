{ pkgs }:

pkgs.fetchFromGitHub {
  owner = "ravsii";
  repo = "tree-sitter-d2";
  rev = "200434618a6bede20ebd4982aa4d4f1edeb0b5c1";
  hash = "sha256-xN6yb7amTu61E8dFHB5Vrv52FOZUKOh3u5zfOIao7rQ=";
}
