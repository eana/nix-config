{
  security.sudo.extraConfig = builtins.concatStringsSep "\n" [
    "jonas ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild"
    "jonas ALL=(ALL) NOPASSWD: /etc/profiles/per-user/jonas/bin/nh"
  ];
}
