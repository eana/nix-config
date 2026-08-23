{ config, pkgs, ... }: {
  age.secrets = {
    home-ssid = {
      file = ../../secrets/home-ssid.age;
      mode = "0400";
      owner = config.module.variables.userName;
      group = if pkgs.stdenv.hostPlatform.isDarwin then "staff" else "users";
    };
    ssh-hosts = {
      file = ../../secrets/ssh-hosts.age;
      mode = "0400";
      owner = config.module.variables.userName;
      group = if pkgs.stdenv.hostPlatform.isDarwin then "staff" else "users";
    };
    atuin = {
      file = ../../secrets/atuin.age;
      mode = "0400";
      owner = config.module.variables.userName;
      group = if pkgs.stdenv.hostPlatform.isDarwin then "staff" else "users";
    };
  };
}
