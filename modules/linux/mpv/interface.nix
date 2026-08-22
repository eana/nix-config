{ lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkOption types;

  pythonWithDeps = pkgs.python3.withPackages (
    ps: with ps; [
      python-dateutil
      ifaddr
      lxml
      requests
      upnpclient
    ]
  );

  mpvWrapped = pkgs.writeShellScriptBin "mpv" ''
    export PATH="${pythonWithDeps}/bin:$PATH"
    export PYTHONPATH="${pythonWithDeps}/${pythonWithDeps.sitePackages}"
    exec ${pkgs.mpv}/bin/mpv "$@"
  '';

  configDir = ../../../assets/.config/mpv;
in
{
  options.module.mpv = {
    enable = mkEnableOption "mpv media player with DLNA support (always includes mpvDLNA)";

    package = mkOption {
      type = types.package;
      default = mpvWrapped;
      description = "mpv media player package with DLNA enabled (wrapped with Python env)";
    };

    config = {
      inputConf = mkOption {
        type = types.path;
        default = configDir + "/input.conf";
        description = "Path to input.conf file";
      };

      mpvConf = mkOption {
        type = types.path;
        default = configDir + "/mpv.conf";
        description = "Path to mpv.conf file";
      };

      dlnaTimeout = mkOption {
        type = types.int;
        default = 5;
        description = "Seconds to spend scanning for DLNA servers via SSDP. Increase if the server is not found reliably.";
      };

      dlnaServers = mkOption {
        type = types.nullOr (types.attrsOf types.str);
        default = null;
        description = ''
          Attrset mapping DLNA server friendly name to its DeviceDescription.xml URL.
          When set, bypasses SSDP discovery and connects directly to the listed servers.
          Example:
            { "Plex Media Server: My-NAS" = "http://192.168.0.145:32469/DeviceDescription.xml"; }
        '';
      };
    };
  };
}
