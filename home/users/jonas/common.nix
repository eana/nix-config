{
  pkgs,
  ...
}:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # File Management
      axel # Download utility
      fd # File search utility
      lsof # List open files
      tree # Directory tree viewer
      unzip # Unzip utility
      wget # Download utility
      zip # Zip utility

      # Media
      mpg123 # Audio player
      (
        let
          # upnpclient package with all dependencies
          upnpclient = python3Packages.buildPythonPackage rec {
            pname = "upnpclient";
            version = "1.0.3";
            src = fetchPypi {
              inherit pname version;
              sha256 = "sha256-ZB8F+kuOXFtcxFYdq0n+XEd00m5RN4Zx761AIySeabg=";
            };
            format = "setuptools";
            propagatedBuildInputs = with python3Packages; [
              dateutil
              ifaddr
              requests
            ];
            doCheck = false;
          };

          # Create a Python environment with all required packages
          pythonWithDeps = python3.withPackages (
            ps: with ps; [
              dateutil
              ifaddr
              lxml
              requests
              upnpclient
            ]
          );

          # Create wrapper scripts for python and python3 that use our custom environment
          pythonWrapper = writeShellScriptBin "python" ''
            exec ${pythonWithDeps}/bin/python "$@"
          '';

          python3Wrapper = writeShellScriptBin "python3" ''
            exec ${pythonWithDeps}/bin/python "$@"
          '';

          # Create mpv wrapper that puts our Python wrappers first in PATH
          mpv-with-deps = writeShellScriptBin "mpv" ''
            export PATH="${pythonWrapper}/bin:${python3Wrapper}/bin:${pythonWithDeps}/bin:$PATH"
            export PYTHONPATH="${pythonWithDeps}/${pythonWithDeps.sitePackages}"
            exec ${mpv}/bin/mpv "$@"
          '';
        in
        mpv-with-deps
      )

      # Development Tools
      fzf # Fuzzy finder
      pre-commit # Framework for managing pre-commit hooks
      ripgrep # Search tool

      # Version Control
      git-absorb # Automatically fixup commits
      lazygit # Simple terminal UI for Git commands
      tig # Text-mode interface for Git

      # File and Text Manipulation
      jaq # JSON processor
      jq # Command-line JSON processor
      xh # Friendly and fast HTTP client

      # Diagramming Tools
      d2 # Modern diagram scripting language

      # Nix Tools
      cachix # Binary cache client for Nix

      # Other
      neofetch # System information tool
      sops # Secrets management tool
      telegram-desktop # Telegram client
    ];

    sessionVariables = {
      LESS = "-iXFR";
      BUILDKIT_PROGRESS = "plain";
      TERM = "xterm-256color";
    };

    stateVersion = "24.05";
  };

  module = {
    git.enable = true;
    gpg-agent.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };
}
