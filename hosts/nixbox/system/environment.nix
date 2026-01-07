{ lib, ... }:

{
  environment = {
    etc = {
      "security/faillock.conf" = {
        text = "deny = 0";
      };
    };

    variables = {
      EDITOR = "nvim";
      MOZ_ENABLE_WAYLAND = "1";
      SSH_ASKPASS = lib.mkForce "";
    };
    wordlist.enable = true;
  };
}
