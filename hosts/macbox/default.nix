{ inputs, ... }:

{
  imports = [
    ./system/defaults.nix
    ./system/packages.nix
    ./system/environment.nix
    ./system/homebrew.nix
    ./home-manager/default.nix
    ./nix/default.nix
  ];

  age.secrets.ssh-hosts = {
    file = ../../secrets/ssh-hosts.age;
    mode = "0444";
  };

  time.timeZone = "Europe/Stockholm";
  system = {
    primaryUser = "jonas";
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    stateVersion = 6;
  };
}
