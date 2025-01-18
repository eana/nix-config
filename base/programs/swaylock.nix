{ pkgs }:

{
  enable = true;
  settings = {
    ignore-empty-password = true;
    clock = true;
    timestr = "%H.%M.%S";
    datestr = "%A, %m %Y";
    image = "~/.config/swaylock/lockscreen.jpg";
    inside-color = "#00000000";
    ring-color = "#00000000";
    indicator-thickness = 4;
    line-uses-ring = true;
  };
}
