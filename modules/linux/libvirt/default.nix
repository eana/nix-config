{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    ;

  cfg = config.module.libvirt;

in
{
  imports = [ ./interface.nix ];

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
