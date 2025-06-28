{ lib, ... }:

{
  environment = {
    variables = {
      EDITOR = "nvim";
      MOZ_ENABLE_WAYLAND = "1";
      SSH_ASKPASS = lib.mkForce "";
    };
    wordlist.enable = true;
  };
}
