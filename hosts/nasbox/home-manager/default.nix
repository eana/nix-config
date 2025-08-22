{
  home-manager = {
    users.root = {
      imports = [
        ../../../home/users/root/ds920p.nix
        ../../../modules/common/default.nix
      ];
      home.stateVersion = "24.05";
    };
  };

  programs.nix-index-database.comma.enable = true;
}
