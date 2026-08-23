{ config, ... }: {
  networking.networkmanager = {
    enable = true;
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
