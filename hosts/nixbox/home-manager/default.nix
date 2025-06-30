{ pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jonas = {
      imports = [
        ../../../home/users/jonas/linux.nix

        # Common modules
        ../../../modules/common/git/default.nix
        ../../../modules/common/gpg-agent/default.nix
        ../../../modules/common/neovim/default.nix
        ../../../modules/common/ollama/default.nix
        ../../../modules/common/tmux/default.nix
        ../../../modules/common/zsh/default.nix

        # Linux-specific modules
        ../../../modules/linux/avizo/default.nix
        ../../../modules/linux/foot/default.nix
        ../../../modules/linux/fuzzel/default.nix
        ../../../modules/linux/gammastep/default.nix
        ../../../modules/linux/kanshi/default.nix
        ../../../modules/linux/mhalo/default.nix
        ../../../modules/linux/openra/default.nix
        ../../../modules/linux/sway/default.nix
        ../../../modules/linux/waybar/default.nix
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
