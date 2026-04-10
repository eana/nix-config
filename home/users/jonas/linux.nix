{
  pkgs,
  ...
}:
let
  theme = {
    package = pkgs.yaru-theme;
    name = "Yaru-prussiangreen";
  };

  aws-export-profile = pkgs.stdenv.mkDerivation {
    name = "aws-export-profile";
    src = pkgs.fetchFromGitHub {
      owner = "cytopia";
      repo = "aws-export-profile";
      rev = "a08ed774a36e5a7386adf645652a4af7b972e208"; # specific commit/tag
      sha256 = "sha256-hvQzKXHfeyN4qm6kEAG/xuIqmHhL8GKpvn8aE+gTMDE=";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp aws-export-profile $out/bin/aws-export-profile.sh
      chmod +x $out/bin/aws-export-profile.sh
    '';
  };

  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.7";
    hash = "sha256-HQtO9cZfPPIkHDj64NeQuG9p9WhSKBVkWGWhZkZjZoo=";
  };
in
{
  imports = [ ./common.nix ];

  programs = {
    opencode = {
      enable = true;
      settings = {
        autoshare = false;
        autoupdate = false;
        experimental.disable_paste_summary = true;
        share = "disabled";
        keybinds = {
          session_export = "none";
          session_share = "none";
          session_unshare = "none";
          terminal_suspend = "none";
          messages_first = "ctrl+home";
          messages_last = "ctrl+end";
        };
        permission = {
          bash = {
            # Don't want it to see my secrets
            "age *" = "deny";
            # In case the command has the "sops" string by chance
            "*age *" = "ask";

            # Don't like it committing without my permission
            "git commit *" = "ask";
            "git push *" = "deny";

            # Scary
            "*terraform destroy*" = "deny";
            "*terraform *" = "ask";
            "*tofu destroy*" = "deny";
            "*tofu *" = "ask";
            "*tf destroy*" = "deny";
            "*tf *" = "ask";
          };
        };
      };
      rules = ''
        # Hacks
        - When you have to write a hack for a limitation in a library, and especially if it's a bug or known issue, try to keep it away from the main logic, and clearly marked.
        - Encapsulate hacks in a clearly named function or module, for example `workaroundForX`.
        - Inline a hack only if it is extremely short and self-contained.
        - Mark every hack with a `HACK:` comment.
        - In the `HACK:` comment include:
          - **Why** the hack exists.
          - A link to the issue or PR if available.
          - A **TODO** with a removal condition or date.
        - Prefer adding a short test that demonstrates the hack's necessity when feasible.
        - Do not let hacks change core business logic or public APIs without explicit review.

        # Comments
        - Explain **why** code exists, assumptions, and trade-offs.
        - Do not write comments that restate the code.
        - Do not write comments that reflect ephemeral conversation.
        - Preserve existing comments unless explicitly asked to remove them.
        - Keep comments concise and factual.

        # Hardcoded Values and Constants
        - Prefer a single source of truth for configuration.
        - Extract a value to a named constant if it is reused or represents a domain concept.
        - Inline truly one-off values at the use site.
        - Name constants clearly and place them near the top of the file.

        # Function Decomposition
        - Prefer clear, well-named functions.
        - Decompose when a block is reusable, improves readability, or enables testing.
        - Use comments to separate logical steps inside a function only when decomposition would add noise.
        - Avoid excessive micro-functions that obscure control flow.

        # Debug Summary
        - Provide a concise debug summary for complex fixes.
        - Include:
          - **Symptoms**
          - **Hypotheses tested**
          - **Commands and logs inspected**
          - **Root cause**
          - **Fix applied**
        - Link to logs, commands, or artifacts when helpful.
        - Keep the summary short; reviewers will ask for details if needed.

        # PR and Issue Inference
        - If the phrase "the PR/issue" or "the current pr/issue" is used with no number, infer it from the current branch name using the GitHub CLI.
        - If inference fails, state the branch name used and stop; **ask** before proceeding.
        - Record the branch name and the inference method in the PR description.

        # Nix and System Constraints
        - The system is NixOS. Treat system configuration as declarative.
        - Do not edit system files directly.
        - Change system configuration by editing declarative files and running `nixos-rebuild switch`.
        - Use `nix`, `nix shell`, or `nix run` to obtain tools.
        - Use `nix-locate` to find items in `/nix/store`.
        - Do not run `find` on `/nix/store`.

        # Environment and Remote Targets
        - Confirm whether the target environment is local or remote before searching for services or installing software.
        - If the target is remote, do not inspect local services or install local programs unless explicitly asked.
        - Ask which environment the code will run in when it is not obvious.

        # Secrets
        - Never decrypt or open secret files.
        - Never run `sops`, `age`, or any secret-decrypting command directly or via `nix run`.
        - Do not open `.env` files or reveal secret contents.
        - You may note that secrets exist and reference their presence without exposing values.

        # File Operations and Cloning
        - Clone repositories for development or persistent work to `~/Code`.
        - Clone repositories for temporary inspection to `/tmp`.
        - If a path is tracked by git, put test files in `/tmp/dirname`.
        - If a path is not tracked by git, you may put test files directly in it.
        - Do not modify tracked files without creating a branch and a commit.

        # Pre-commit Hooks and CI
        - Run pre-commit hooks before committing.
        - Fix issues reported by pre-commit locally.
        - Do not bypass or disable pre-commit hooks.
        - Ensure CI passes before requesting review.
        - Add tests for behavior changes when feasible.
        - Document any intentional pre-commit exceptions in the PR description.

        # Idempotency and Destructive Operations
        - Prefer idempotent scripts and operations.
        - Design scripts so repeated runs are safe.
        - Avoid destructive operations without explicit confirmation.
        - Require explicit, documented approval for any destructive change such as:
          - Data deletion
          - Irreversible migrations
          - Force-pushes to shared branches
        - Log and document any destructive action taken.
        - Provide a rollback plan for destructive changes.

        # Testing and Quality
        - Add unit tests for new logic and bug fixes.
        - Add regression tests for fixed bugs.
        - Place tests according to repository conventions.
        - Run linters and formatters locally before committing.
        - Follow repository pre-commit and CI rules.
        - Include integration tests for cross-service behavior when applicable.

        # Git Commit Messages and Branching
        - Write a short summary line.
        - Add a body that explains the why and what.
        - Reference issue or PR numbers in the commit body.
        - Use feature branch names that describe the work and include the issue number when applicable.
        - Rebase to keep history linear unless policy requires merge commits.
        - Squash trivial fixup commits before merging.

        # Security and Dependencies
        - Run dependency checks and static analysis when adding or updating dependencies.
        - Report vulnerabilities immediately and follow escalation procedures.
        - Prefer minimal dependency additions.
        - Pin dependency versions when reproducibility matters.

        # Reviews and Collaboration
        - Request reviewers relevant to the code area.
        - Include reproduction steps, branch, and failing CI links in the PR description.
        - Address review comments promptly.
        - Summarize changes made in response to reviews in the PR.

        # General Rules
        - Do not remove comments unless explicitly asked.
        - Do not snoop into secrets.
        - Do not search `/nix/store` with `find`.
        - Ask before restoring code that appears intentionally removed.
        - Be concise and explicit in changes and communications.
        - Use the two OpenCode skills for coding style and commit messages: apply coding style rules and follow commit message conventions.

        # Quick Checklist for PRs
        - Run pre-commit hooks.
        - Run tests locally.
        - Ensure CI passes.
        - Add or update tests for behavior changes.
        - Include a debug summary if applicable.
        - Mark hacks with `HACK:` and TODO for removal.
        - Confirm no secrets were accessed.
        - Confirm idempotency or obtain explicit approval for destructive steps.
        - Reference issue/PR numbers and branch name.

        # Optional Policies to Enforce
        - Require unit tests for new logic and regression tests for bug fixes.
        - Require repository standard formatters and pre-commit format checks.
        - Require issue reference and conventional commit style if desired.
        - Require migration plans and feature flags for risky changes.
      '';
      skills = {
        # keep-sorted start
        git-commit = ../../../assets/.config/opencode/skills/git-commit;
        style = ../../../assets/.config/opencode/skills/style;
        superpowers-brainstorming = "${superpowersSrc}/skills/brainstorming";
        superpowers-dispatching-parallel-agents = "${superpowersSrc}/skills/dispatching-parallel-agents";
        superpowers-executing-plans = "${superpowersSrc}/skills/executing-plans";
        superpowers-finishing-a-development-branch = "${superpowersSrc}/skills/finishing-a-development-branch";
        superpowers-receiving-code-review = "${superpowersSrc}/skills/receiving-code-review";
        superpowers-requesting-code-review = "${superpowersSrc}/skills/requesting-code-review";
        superpowers-subagent-driven-development = "${superpowersSrc}/skills/subagent-driven-development";
        superpowers-systematic-debugging = "${superpowersSrc}/skills/systematic-debugging";
        superpowers-test-driven-development = "${superpowersSrc}/skills/test-driven-development";
        superpowers-using-git-worktrees = "${superpowersSrc}/skills/using-git-worktrees";
        superpowers-using-superpowers = "${superpowersSrc}/skills/using-superpowers";
        superpowers-verification-before-completion = "${superpowersSrc}/skills/verification-before-completion";
        superpowers-writing-plans = "${superpowersSrc}/skills/writing-plans";
        superpowers-writing-skills = "${superpowersSrc}/skills/writing-skills";
        # keep-sorted end
      };
    };
  };

  systemd.user = {
    startServices = "sd-switch";

    services = {
      copyq = {
        Unit = {
          Description = "CopyQ clipboard management daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.copyq}/bin/copyq";
          Restart = "on-failure";
          Environment = [ "QT_QPA_PLATFORM=xcb" ];
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      telegram = {
        Unit = {
          Description = "Telegram Desktop";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.telegram-desktop}/bin/Telegram -startintray";
          Restart = "on-failure";
          Environment = [ "QT_QPA_PLATFORM=xcb" ];
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      bluetooth-applet = {
        Unit = {
          Description = "Blueman Applet";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.blueman}/bin/blueman-applet";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };

      swaynag-battery = {
        Unit = {
          Description = "Low battery notification";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swaynag-battery}/bin/swaynag-battery";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "sway-session.target" ];
      };
    };
  };

  dconf = {
    settings = {
      "org/gnome/desktop/interface" = {
        font-name = "Helvetica Neue LT Std";
        monospace-font-name = "Source Code Pro";
        document-font-name = "Cantarell";
      };
    };
  };

  gtk = {
    enable = true;

    inherit theme;
    iconTheme = theme;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 0;
    gtk4 = {
      inherit theme;
      extraConfig.gtk-application-prefer-dark-theme = 0;
    };
  };

  # Install packages for user.
  # Search for packages here: https://search.nixos.org/packages
  home = {
    packages = with pkgs; [
      # File Management
      gthumb # Image browser and viewer

      # Networking
      iproute2 # Utilities for controlling TCP/IP networking and traffic control in Linux
      protonvpn-gui # ProtonVPN

      # Media
      freetube # YouTube client

      # Development Tools
      aws-export-profile # AWS profile exporter
      nix-tree # Visualize Nix dependencies

      # Fonts
      cantarell-fonts # Cantarell font family

      # Development Tools
      aws-export-profile # AWS profile exporter
      awscli2 # AWS command-line interface
      nix-tree # Visualize Nix dependencies
      oath-toolkit # OATH one-time password tool

      # Emulators
      fuse-emulator # ZX Spectrum (Z80) emulator

      # Browsers
      firefox # Web browser
      google-chrome # Web browser
    ];

    sessionVariables = {
      LIBGL_ALWAYS_INDIRECT = 1;
      DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
      KPT_FN_RUNTIME = "podman";
    };
  };

  module = {
    avizo.enable = true;
    foot.enable = true;
    fuzzel.enable = true;
    gammastep.enable = true;
    kanshi.enable = true;
    mhalo = {
      enable = true;
      swayKeybinding = "Mod4+Shift+m";
    };
    mpv.enable = true;
    ollama.enable = true;
    openra.enable = false;
    sway = {
      enable = true;
      background = "~/.local/share/backgrounds/hannah-grace-dSqWwzrLJaQ-unsplash.jpg";
      swaylock = {
        enable = true;
        settings.indicator-radius = 45;
      };
    };
    waybar = {
      enable = true;
      systemdIntegration.enable = true;
    };
  };
}
