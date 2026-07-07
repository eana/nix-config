{ pkgs, ... }: {
  age.secrets = {
    ssh-hosts = {
      file = ../../secrets/ssh-hosts.age;
      mode = "0400";
      owner = "jonas";
      group = if pkgs.stdenv.hostPlatform.isDarwin then "staff" else "users";
    };
    atuin = {
      file = ../../secrets/atuin.age;
      mode = "0400";
      owner = "jonas";
      group = if pkgs.stdenv.hostPlatform.isDarwin then "staff" else "users";
    };
  };
}
