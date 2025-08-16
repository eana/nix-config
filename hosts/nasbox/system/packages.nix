{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      curl
      dive
      docker-compose
      podman-tui
      zsh-powerlevel10k
    ];
  };
}
