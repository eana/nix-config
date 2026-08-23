{ config, lib, ... }: {
  options.module.variables = {
    dnsServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.0.145" ];
      description = "Custom DNS servers";
    };
    fallbackDns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      description = "DNS servers for non-home networks (Cloudflare + Quad9)";
    };
    userName = lib.mkOption {
      type = lib.types.str;
      default = "jonas";
      description = "Primary user name";
    };
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Stockholm";
      description = "System time zone";
    };
    knownNetworkServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Wi-Fi" ];
      description = "Darwin network services to manage";
    };
  };

  config.time.timeZone = config.module.variables.timeZone;
}
