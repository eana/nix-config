_: {
  networking = {
    knownNetworkServices = [ "Wi-Fi" ];
    dns = [ "192.168.0.145" ];
  };

  security.sudo.extraConfig = ''
    jonas ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}
