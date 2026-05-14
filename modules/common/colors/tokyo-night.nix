# Canonical Tokyo Night color palette.
# hex: raw hex strings (no '#') — used by foot and similar terminals
# withHash: '#'-prefixed strings — used by kitty and similar terminals
let
  base = {
    foreground = "c0caf5";
    background = "1a1b26";
    black = "81807f";
    red = "f7768e";
    green = "9ece6a";
    yellow = "e0af68";
    blue = "7aa2f7";
    magenta = "bb9af7";
    cyan = "7dcfff";
    white = "a9b1d6";
    brightBlack = "414868";
    brightRed = "f7768e";
    brightGreen = "9ece6a";
    brightYellow = "e0af68";
    brightBlue = "7aa2f7";
    brightMagenta = "bb9af7";
    brightCyan = "7dcfff";
    brightWhite = "c0caf5";
    # foot-specific dim colors (no standard kitty equivalent)
    dim0 = "ff9e64";
    dim1 = "db4b4b";
  };
in
{
  hex = base;
  withHash = builtins.mapAttrs (_: v: "#${v}") base;
}
