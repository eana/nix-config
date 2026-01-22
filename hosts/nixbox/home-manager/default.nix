{
  pkgs,
  config,
  inputs,
  ...
}:
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
        # keep-sorted start
        ../../../home/users/jonas/linux.nix
        ../../../modules/common/default.nix
        ../../../modules/linux/default.nix
        # keep-sorted end
      ];
    };

    extraSpecialArgs = { inherit inputs; };
  };

  programs = {
    # keep-sorted start
    nix-index-database.comma.enable = true;
    ssh.startAgent = true;
    sway.enable = true;
    ydotool.enable = true;
    zsh.enable = true;
    # keep-sorted end
  };

  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [
      # keep-sorted start
      "video"
      "wheel"
      "ydotool"
      # keep-sorted end
    ];
  };

  users.defaultUserShell = pkgs.zsh;
}
