{ pkgs }:

{
  # fstrim requires this to work
  # sudo cryptsetup --allow-discards --persistent refresh nixos
  fstrim = {
    enable = true;
    interval = "weekly";
  };

  pipewire = {
    enable = true;
    pulse.enable = true;
  };

  avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  blueman.enable = true;

  displayManager = {
    defaultSession = "sway";
  };

  xserver = {
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
        settings = {
          greeter = {
            IncludeAll = true;
          };
        };
      };
    };
    desktopManager.gnome.enable = true;
  };

  printing = {
    enable = true;
    drivers = [ pkgs.canon-cups-ufr2 ];
  };

  libinput.enable = true;
  dbus.enable = true;
  openssh.enable = true;

  logind.lidSwitchExternalPower = "ignore";
}
