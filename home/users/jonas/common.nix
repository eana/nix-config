{
  lib,
  pkgs,
  sshSecretsPath ? null,
  atuinSecretsPath ? null,
  ...
}:
let
  # Pin opencode to 1.14.25 on x86_64-darwin: newer releases drop support for
  # that platform. bun install uses --os="*" --cpu="*" so node_modules hash is
  # platform-independent.
  opencodeForDarwin =
    let
      version = "1.14.25";
      src = pkgs.fetchFromGitHub {
        owner = "anomalyco";
        repo = "opencode";
        tag = "v${version}";
        hash = "sha256-v1aaq4HWAJ5wZm9bUeaRkyKr0iYjdOhigr/I31wwhEk=";
      };
    in
    pkgs.opencode.overrideAttrs (old: {
      inherit version src;
      node_modules = old.node_modules.overrideAttrs (_: {
        inherit src;
        outputHash = "sha256-r0UCWhxIB4q4Te+LpXNcfexjfmI4Th2swfWOL3cUp3g=";
      });
      meta = old.meta // {
        platforms = (old.meta.platforms or [ ]) ++ [ "x86_64-darwin" ];
        badPlatforms = lib.remove "x86_64-darwin" (old.meta.badPlatforms or [ ]);
      };
    });
in
{
  imports = [ ../shared.nix ];

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    # File Management
    fd # File search utility
    lsof # List open files
    wget # Download utility
    zip # Zip utility

    # Networking
    inetutils # Collection of common network programs (ftp, telnet, etc.)
    net-tools # Network tools (ifconfig, netstat, etc.)

    # Media
    mpg123 # Audio player

    # Development Tools
    pre-commit # Framework for managing pre-commit hooks
    ripgrep # Search tool

    # Version Control
    git-absorb # Automatically fixup commits

    # File and Text Manipulation
    jaq # JSON processor
    jq # Command-line JSON processor
    xh # Friendly and fast HTTP client

    # Diagramming Tools
    # HACK: pkgs.d2 gained mesa-libgbm as a build input after the nixpkgs
    # lock update, which transitively requires libdrm (Linux-only). Guard it
    # so macbox does not attempt to evaluate the Linux-only dep chain.
    # TODO: remove the guard once nixpkgs fixes d2 darwin compatibility.
    (lib.mkIf stdenv.isLinux d2)

    # Security & Encryption
    age # Simple, modern and secure encryption tool

    # Messaging apps
    telegram-desktop # Telegram client
  ];

  home.sessionVariables = {
    BUILDKIT_PROGRESS = "plain";
    TERM = "xterm-256color";
  };

  module = {
    atuin = {
      enable = true;
      sync = {
        enable = true;
        address = "https://atuin.eana.win";
        credentialsFile = atuinSecretsPath;
      };
      settings = {
        sync_frequency = "10m";
        search_mode = "fuzzy";
      };
    };

    kitty = {
      enable = true;
      keybindings = {
        "shift+enter" = "send_text all \\x1b[13;2u";
        "ctrl+enter" = "send_text all \\x1b[13;5u";
      };
    };

    neovim.enable = false;

    opencode = {
      enable = true;
      package = if pkgs.stdenv.isDarwin then opencodeForDarwin else pkgs.opencode;
    };

    ssh-client = {
      enable = true;

      # Add hosts here that do not contain sensitive information.
      # hosts = {
      #   "xxx" = {
      #     hostname = "xxx";
      #     user = "xxx";
      #     port = 1111;
      #     identityFile = "~/.ssh/id_ed25519";
      #   };
      # };

      secretsFile = sshSecretsPath;

      globalOptions = {
        KexAlgorithms = "sntrup761x25519-sha512@openssh.com,curve25519-sha256";
      };
    };
  };
}
