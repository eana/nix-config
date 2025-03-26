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
    videoDrivers = [ ];
    # Disable the nvidia driver and use the intel one instead
    # [
    #   "nvidia"
    # ];
  };

  printing = {
    enable = true;
    drivers = [ pkgs.canon-cups-ufr2 ];
  };

  libinput.enable = true;
  dbus.enable = true;
  openssh.enable = true;

  logind.lidSwitchExternalPower = "ignore";

  # Disable the nvidia driver and use the intel one instead
  udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"

    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
}
