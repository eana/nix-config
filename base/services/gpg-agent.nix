{ pkgs }:

{
  enable = true;
  defaultCacheTtl = 86400;
  maxCacheTtl = 86400;
  pinentry.package = pkgs.pinentry-tty;
}
