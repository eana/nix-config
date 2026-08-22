{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.module.mpv;

  mpvDLNA = pkgs.fetchFromGitHub {
    owner = "chachmu";
    repo = "mpvDLNA";
    rev = "v3.4.1";
    sha256 = "sha256-FOWHoC2s1wK1UbUbJxuos0/9+238cFU5u8T8xqqI8ko=";
  };

in
{
  imports = [ ./interface.nix ];

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
