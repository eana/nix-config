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

  users.users.jonas = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "wheel"
      "ydotool"
    ];
  };

  users.defaultUserShell = pkgs.zsh;
}
