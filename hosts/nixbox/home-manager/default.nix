{ pkgs, ... }:

{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
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
