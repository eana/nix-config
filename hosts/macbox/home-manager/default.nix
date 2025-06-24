{ pkgs, ... }:

{
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
      imports = [
        ../../../home/users/jonas/darwin.nix

        # Common modules
        ../../../modules/common/git/default.nix
        ../../../modules/common/gpg-agent/default.nix
        ../../../modules/common/neovim/default.nix
        ../../../modules/common/ollama/default.nix
        ../../../modules/common/tmux/default.nix
        ../../../modules/common/zsh/default.nix
      ];
      home.packages = [
        pkgs.spotify
      ];
      home.stateVersion = "24.05";
    };
  };

}
