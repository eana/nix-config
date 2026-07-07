_: {
  networking.networkmanager = {
    enable = true;
    insertNameservers = [ "192.168.0.145" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "jonas" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
