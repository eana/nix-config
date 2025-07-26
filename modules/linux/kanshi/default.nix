{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.module.kanshi;

  swaymsg = "${pkgs.sway}/bin/swaymsg";

  defaultSettings = [
    {
      profile = {
        name = "MonitorAndLaptop";
        exec = [
          "${swaymsg} workspace 1, move workspace to output '\"Dell Inc. DELL U2718Q FN84K0120PNL\"'"
          "${swaymsg} workspace 2, move workspace to output '\"Dell Inc. DELL U2718Q FN84K0120PNL\"'"
          "${swaymsg} workspace 3, move workspace to output '\"Dell Inc. DELL U2718Q FN84K0120PNL\"'"
        ];
        outputs = [
          {
            criteria = "Dell Inc. DELL U2718Q FN84K0120PNL";
            status = "enable";
            mode = "3840x2160";
            position = "0,0";
            scale = 1.4;
          }
          {
            criteria = "Sharp Corporation 0x1453 Unknown";
            status = "disable";
            mode = "1920x1080";
            position = "540,2160";
            scale = 1.0;
          }
        ];
      };
    }
    {
      profile = {
        name = "LaptopOnly";
        outputs = [
          {
            criteria = "Sharp Corporation 0x1453 Unknown";
            status = "enable";
            mode = "1920x1080";
            position = "540,2160";
            scale = 0.8;
          }
        ];
      };
    }
  ];

in
{
  options.module.kanshi = {
    enable = mkEnableOption "Kanshi display configuration manager";

    package = mkOption {
      type = types.package;
      default = pkgs.kanshi;
      description = "Dynamic display configuration tool";
    };

    settings = mkOption {
      type = types.listOf types.attrs;
      default = defaultSettings;
      description = "Kanshi output profiles and configurations";
    };
  };

  config = lib.mkIf cfg.enable {
    services.kanshi = {
      enable = true;
      inherit (cfg) settings;
    };

    home.packages = [ cfg.package ];
  };
}
