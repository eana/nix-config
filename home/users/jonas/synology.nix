{
  pkgs,
  ...
}:
{
  imports = [ ./common.nix ];

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # Development Tools
      nix-tree # Visualize Nix dependencies

      # Containers
      podman # Tool for managing OCI containers
    ];

    sessionVariables = {
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      KPT_FN_RUNTIME = "podman";
    };
  };
}
