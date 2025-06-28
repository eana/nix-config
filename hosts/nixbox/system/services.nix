{ pkgs, ... }:

{
  services = {
    # fstrim requires this to work
    # sudo cryptsetup --allow-discards --persistent refresh nixos
    fstrim = {
      enable = true;
      interval = "weekly";
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

    printing = {
      enable = true;
      drivers = [ pkgs.canon-cups-ufr2 ];
    };

    libinput.enable = true;
    dbus.enable = true;
    openssh.enable = true;

    logind.lidSwitchExternalPower = "ignore";

    # Disable GCR SSH as it is incompatible with gpg-agent's SSH support.
    gnome.gcr-ssh-agent.enable = false;

    # Limit storage space of journald.
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=100M
    '';
  };
}
