{ inputs, ... }:

{
  imports = [
    ./system/defaults.nix
    ./system/packages.nix
    ./system/networking.nix
    ./system/environment.nix
    ./system/homebrew.nix
    ./home-manager/default.nix
    ./nix/default.nix
  ];

  age.secrets = {
    ssh-hosts = {
      file = ../../secrets/ssh-hosts.age;
      mode = "0400";
      owner = "jonas";
      group = "staff";
    };
    atuin = {
      file = ../../secrets/atuin.age;
      mode = "0400";
      owner = "jonas";
      group = "staff";
    };
  };

  time.timeZone = "Europe/Stockholm";
  system = {
    primaryUser = "jonas";
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    stateVersion = 6;
  };
}
