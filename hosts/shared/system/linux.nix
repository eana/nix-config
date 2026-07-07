{ config, ... }: {
  networking.networkmanager = {
    enable = true;
    insertNameservers = config.module.variables.dnsServers;
  };

  security.sudo.extraRules = [
    {
      users = [ config.module.variables.userName ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
