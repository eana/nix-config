{ pkgs }:

{
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

  # This fails to build with the following error:
  # ERROR: noBrokenSymlinks: the symlink /nix/store/nwxj5wdhp35b2niwl6xw4qapsngbkfnn-canon-cups-ufr2-6.00/lib/libuictlufr2r.so points to a missing target /nix/store/nwxj5wdhp35b2niwl6xw4qapsngbkfnn-canon-cups-ufr2-6.00/lib/libuictlufr2r.so.1.0.0
  # ERROR: noBrokenSymlinks: the symlink /nix/store/nwxj5wdhp35b2niwl6xw4qapsngbkfnn-canon-cups-ufr2-6.00/lib/libuictlufr2r.so.1 points to a missing target /nix/store/nwxj5wdhp35b2niwl6xw4qapsngbkfnn-canon-cups-ufr2-6.00/lib/libuictlufr2r.so.1.0.0
  # ERROR: noBrokenSymlinks: found 2 dangling symlinks and 0 reflexive symlinks
  # Re-enable when this PR is merged:
  # https://github.com/NixOS/nixpkgs/pull/381315
  #
  # Additional info:
  # https://github.com/NixOS/nixpkgs/issues/380572
  # printing = {
  #   enable = true;
  #   drivers = [ pkgs.canon-cups-ufr2 ];
  # };

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
