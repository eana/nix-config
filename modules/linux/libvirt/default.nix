{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;

  cfg = config.module.libvirt;

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
      default = "jonas";
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

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;

      qemu = lib.mkMerge [
        {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        }
        cfg.daemonSettings
      ];
    };

    boot.kernelModules = lib.optional (cfg.platformCpu != null) "kvm-${cfg.platformCpu}";

    programs.virt-manager = mkIf cfg.gui.enable {
      enable = true;
      inherit (cfg) package;
    };

    environment.systemPackages = mkIf cfg.gui.enable [
      cfg.package
      pkgs.spice-gtk
    ];

    programs.dconf.enable = mkIf cfg.gui.enable true;
    virtualisation.spiceUSBRedirection.enable = mkIf cfg.gui.enable true;

    users.users.${config.module.libvirt.user}.extraGroups = [ "libvirtd" ];
  };
}
