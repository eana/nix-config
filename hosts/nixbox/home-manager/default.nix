{ pkgs, config, ... }:
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
        ../../../home/users/jonas/linux.nix
        ../../../modules/common/default.nix
        ../../../modules/linux/default.nix
      ];
    };
  };

  programs = {
    zsh.enable = true;
    sway.enable = true;
    ydotool.enable = true;
    nix-index-database.comma.enable = true;
    ssh.startAgent = true;
  };

  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "ydotool"
    ];
  };

  users.defaultUserShell = pkgs.zsh;
}
