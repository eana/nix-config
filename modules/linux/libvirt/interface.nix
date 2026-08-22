{ lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
in
{
  options.module.libvirt = {
    enable = mkEnableOption "KVM and libvirt virtualization stack";

    package = mkOption {
      type = types.package;
      default = pkgs.virt-manager;
      description = "The virt-manager package to use for the GUI client.";
    };

    user = mkOption {
      type = types.str;
      description = "The primary user to be added to the libvirtd group.";
    };

    gui = {
      enable = mkEnableOption "virt-manager GUI client";
    };

    platformCpu = mkOption {
      type = types.nullOr (
        types.enum [
          "intel"
          "amd"
        ]
      );
      default = null;
      description = "CPU vendor for specific KVM kernel modules (kvm-intel/kvm-amd).";
    };

    daemonSettings = mkOption {
      type = types.attrs;
      default = { };
      description = "Additional configuration passed to virtualisation.libvirtd.qemu";
    };
  };
}
