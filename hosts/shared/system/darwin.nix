{ config, ... }: {
  networking = {
    knownNetworkServices = config.module.variables.knownNetworkServices;
    dns = config.module.variables.dnsServers;
  };

  security.sudo.extraConfig = ''
    ${config.module.variables.userName} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}
