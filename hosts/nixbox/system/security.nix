{
  security = {
    pam.services.swaylock = { };
    pam.services.swaylock.fprintAuth = false;

    sudo.extraRules = [
      {
        users = [ "jonas" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/etc/profiles/per-user/jonas/bin/nh";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
