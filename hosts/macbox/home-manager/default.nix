{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
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
