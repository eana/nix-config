{ lib, ... }:

{
  environment = {
    etc = {
      "security/faillock.conf" = {
        text = "deny = 0";
      };
    };

    variables = {
      MOZ_ENABLE_WAYLAND = "1";
      SSH_ASKPASS = lib.mkForce "";
    };
    wordlist.enable = true;
  };
}
