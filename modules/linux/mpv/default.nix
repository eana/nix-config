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

  upnpclient = pythonPkgs.buildPythonPackage rec {
    pname = "upnpclient";
    version = "1.0.3";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-ZB8F+kuOXFtcxFYdq0n+XEd00m5RN4Zx761AIySeabg=";
    };
    format = "setuptools";
    propagatedBuildInputs = with pythonPkgs; [
      dateutil
      ifaddr
      requests
    ];
    doCheck = false;

    meta = with pkgs.lib; {
      description = "Python UPnP client library used by mpvDLNA";
      homepage = "https://github.com/StevenLooman/upnpclient";
      license = licenses.mit;
    };
  };

  pythonWithDeps = pkgs.python3.withPackages (
    ps: with ps; [
      dateutil
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
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "mpv/input.conf".source = cfg.config.inputConf;
      "mpv/mpv.conf".source = cfg.config.mpvConf;
      "mpv/scripts/mpvDLNA".source = mpvDLNA;
    };
  };
}
