{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.eana.nightShift) start end;
in
{
  options.eana.nightShift = {
    start = lib.mkOption {
      type = lib.types.str;
      default = "19:00";
      description = "Night Shift start time (24h)";
    };
    end = lib.mkOption {
      type = lib.types.str;
      default = "9:00";
      description = "Night Shift end time (24h)";
    };
  };

  config.launchd.agents.night-shift = {
    enable = true;
    config = {
      Label = "com.eana.night-shift";
      ProgramArguments = [
        "${pkgs.nightlight}/bin/nightlight"
        "schedule"
        start
        end
      ];
      RunAtLoad = true; # Apply schedule at login
      KeepAlive = false; # Runs once; brightnessd persists the setting

      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/night-shift.out.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/night-shift.err.log";
    };
  };
}
