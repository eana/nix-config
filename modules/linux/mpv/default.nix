{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.module.mpv;
  inherit (lib) mkEnableOption mkOption types;

  pythonPkgs = pkgs.python3Packages;

  upnpclient = pythonPkgs.buildPythonPackage {
    pname = "upnpclient";
    version = "2.0.3";
    src = pkgs.fetchPypi {
      pname = "upnpclient";
      version = "2.0.3";
      sha256 = "sha256-rPZngaGU8mhTn7ylLr+hsQ3hIXTHFQkCBT2f0KKgLFw=";
    };
    format = "pyproject";
    nativeBuildInputs = with pythonPkgs; [ hatchling ];
    propagatedBuildInputs = with pythonPkgs; [
      python-dateutil
      ifaddr
      lxml
      requests
    ];
    doCheck = false;

    meta = {
      description = "Python UPnP client library used by mpvDLNA";
      homepage = "https://github.com/flyte/upnpclient";
      license = lib.licenses.mit;
    };
  };

  pythonWithDeps = pkgs.python3.withPackages (
    ps: with ps; [
      python-dateutil
      ifaddr
      lxml
      requests
      upnpclient
    ]
  );

  mpvDLNA = pkgs.fetchFromGitHub {
    owner = "chachmu";
    repo = "mpvDLNA";
    rev = "v3.4.1";
    sha256 = "sha256-FOWHoC2s1wK1UbUbJxuos0/9+238cFU5u8T8xqqI8ko=";
  };

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

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "mpv/input.conf".source = cfg.config.inputConf;
      "mpv/mpv.conf".source = cfg.config.mpvConf;
      "mpv/scripts/mpvDLNA".source = mpvDLNA;
      "mpv/script-settings/mpvDLNA.conf".text =
        "timeout=${toString cfg.config.dlnaTimeout}\n"
        + lib.optionalString (cfg.config.dlnaServers != null) (
          "server_names="
          + lib.concatMapStringsSep "+" (n: "{${n}}") (lib.attrNames cfg.config.dlnaServers)
          + "\n"
          + "server_addrs="
          + lib.concatMapStringsSep "+" (a: "{${a}}") (lib.attrValues cfg.config.dlnaServers)
          + "\n"
        );
    };
  };
}
