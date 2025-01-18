{ pkgs }:

{
  enable = true;
  defaultCacheTtl = 86400;
  maxCacheTtl = 86400;
  pinentryPackage = pkgs.pinentry-tty;
}
