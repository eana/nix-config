{ pkgs, ... }:

{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
      imports = [
        ../../../home/users/jonas/synology.nix
        ../../../modules/common/default.nix
        ../../../modules/linux/default.nix
      ];
    };
  };

  programs = {
    zsh.enable = true;
    nix-index-database.comma.enable = true;
    ssh.startAgent = true;
  };

  users.defaultUserShell = pkgs.zsh;
}
