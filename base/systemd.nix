{ pkgs, ... }:

{
  startServices = "sd-switch";

  services = {
    copyq = {
      Unit = {
        Description = "CopyQ clipboard management daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.copyq}/bin/copyq";
        Restart = "on-failure";
        Environment = [ "QT_QPA_PLATFORM=xcb" ];
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    telegram = {
      Unit = {
        Description = "Telegram Desktop";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.telegram-desktop}/bin/telegram-desktop -startintray";
        Restart = "on-failure";
        Environment = [ "QT_QPA_PLATFORM=xcb" ];
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    bluetooth-applet = {
      Unit = {
        Description = "Blueman Applet";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.blueman}/bin/blueman-applet";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };

    swaynag-battery = {
      Unit = {
        Description = "Low battery notification";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swaynag-battery}/bin/swaynag-battery";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
