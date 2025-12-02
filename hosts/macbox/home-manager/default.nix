{ config, ... }:
{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
      _module.args = {
        sshSecretsPath = config.age.secrets.ssh-hosts.path;
        atuinSecretsPath = config.age.secrets.atuin.path;
      };
      imports = [
        ../../../home/users/jonas/darwin.nix
        ../../../modules/common/default.nix
      ];
      home.packages = [ ];
      home.stateVersion = "24.05";
    };
  };

  programs.nix-index-database.comma.enable = true;
}
