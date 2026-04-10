{
  pkgs,
  sshSecretsPath ? null,
  atuinSecretsPath ? null,
  ...
}:
let
  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.7";
    hash = "sha256-HQtO9cZfPPIkHDj64NeQuG9p9WhSKBVkWGWhZkZjZoo=";
  };
in
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
    opencode = {
      enable = true;
      settings = {
        autoshare = false;
        autoupdate = false;
        experimental.disable_paste_summary = true;
        keybinds = {
          session_export = "none";
          session_share = "none";
          session_unshare = "none";
          terminal_suspend = "none";
          messages_first = "ctrl+home";
          messages_last = "ctrl+end";
        };
        share = "disabled";
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

  services.ssh-agent.enable = true;

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

      # Networking
      inetutils # Collection of common network programs (ftp, telnet, etc.)
      net-tools # Network tools (ifconfig, netstat, etc.)

      # Media
      mpg123 # Audio player

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

      # System Information
      fastfetch # System information tool

      # Security & Encryption
      age # Simple, modern and secure encryption tool

      # Messaging apps
      telegram-desktop # Telegram client
    ];

    sessionVariables = {
      LESS = "-iXFR";
      BUILDKIT_PROGRESS = "plain";
      TERM = "xterm-256color";
    };

    stateVersion = "26.05";
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

    git.enable = true;
    gpg-agent.enable = true;
    kitty = {
      enable = true;
      keybindings = {
        "shift+enter" = "send_text all \\x1b[13;2u";
        "ctrl+enter" = "send_text all \\x1b[13;5u";
      };
    };
    neovim.enable = false;
    nixvim.enable = true;

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

    tmux.enable = true;
    zsh.enable = true;
  };
}
