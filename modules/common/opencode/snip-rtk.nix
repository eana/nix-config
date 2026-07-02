{ lib, pkgs }:
{
  home.packages = [
    pkgs.snip
    pkgs.rtk
  ];

  home.activation.rtkOpencode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export RTK_TELEMETRY_DISABLED=1
    ${pkgs.rtk}/bin/rtk init -g --opencode --auto-patch
  '';

  xdg.configFile."snip/config.toml".source = ../../../assets/.config/snip/config.toml;
}
