{
  pkgs,
  ...
}:

{
  imports = [ ./common.nix ];

  module.aerospace.enable = true;
  module.aerospace.modifier = "cmd";

  services.ollama = {
    enable = true;
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_MAX_LOADED_MODELS = "1";
    };
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      cmake # Build system
      mas # Mac App Store command-line interface

      maccy # Lightweight clipboard manager

      # Networking
      iproute2mac # Utilities for controlling TCP/IP networking and traffic control in Linux
    ];
  };
}
