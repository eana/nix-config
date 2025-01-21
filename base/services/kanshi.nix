{ pkgs }:
let
  swaymsg = "${pkgs.sway}/bin/swaymsg";
in
{
  enable = true;
  settings = [
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
            scale = 1.0;
          }

          {
            criteria = "Sharp Corporation 0x1453 Unknown";
            status = "enable";
            mode = "1920x1080";
            position = "540,2160";
            scale = 0.7;
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
            scale = 0.7;
          }
        ];
      };
    }
  ];
}
