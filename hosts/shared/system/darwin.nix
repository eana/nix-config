{ config, ... }: {
  networking = {
    knownNetworkServices = config.module.variables.knownNetworkServices;
  };

  security.sudo.extraConfig = ''
    ${config.module.variables.userName} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}
