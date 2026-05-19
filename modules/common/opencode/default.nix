{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.module.opencode;

  superpowersSrc = pkgs.fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v5.0.7";
    hash = "sha256-HQtO9cZfPPIkHDj64NeQuG9p9WhSKBVkWGWhZkZjZoo=";
  };

  opentofu-mcp-server = pkgs.callPackage ./packages/opentofu-mcp-server.nix { };

  context-mode = pkgs.callPackage ./packages/context-mode.nix { };

  mcp-nixos = pkgs.callPackage ./packages/mcp-nixos.nix { };

  defaultSkills = {
    # keep-sorted start
    ghq-lookup = ../../../assets/.config/opencode/skills/ghq-lookup;
    git-commit = ../../../assets/.config/opencode/skills/git-commit;
    gitlab-cli-tool = ../../../assets/.config/opencode/skills/gitlab-cli-tool;
    skill-creator = ../../../assets/.config/opencode/skills/skill-creator;
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

  baseContext = ''
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
    - Do NOT run `find` on `/nix/store`.

    # Environment and Remote Targets
    - Confirm whether the target environment is local or remote before searching for services or installing software.
    - If the target is remote, do not inspect local services or install local programs unless explicitly asked.
    - Ask which environment the code will run in when it is not obvious.

    # Secrets
    - Never decrypt or open secret files.
    - Never run `sops`, `age`, or any secret-decrypting command directly or via `nix run`.
    - Do NOT open `.env` files or reveal secret contents.
    - You may note that secrets exist and reference their presence without exposing values.

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
    - Do NOT remove comments unless explicitly asked.
    - Do NOT snoop into secrets.
    - Do NOT search `/nix/store` with `find`.
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
in
{
  options.module.opencode = {
    enable = mkEnableOption "opencode";

    package = mkOption {
      type = types.package;
      default = pkgs.opencode;
      defaultText = literalExpression "pkgs.opencode";
      description = "The opencode package to use.";
    };

    extraSkills = mkOption {
      type = types.attrsOf types.path;
      default = { };
      description = "Skills merged on top of the default set.";
    };

    extraContext = mkOption {
      type = types.lines;
      default = "";
      description = "Context appended after the base context.";
    };
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      inherit (cfg) package;

      settings = {
        autoshare = false;
        autoupdate = false;
        experimental.disable_paste_summary = true;
        share = "disabled";

        permission.bash = {
          # age: deny direct invocations to prevent secret exposure; ask on
          # incidental matches where "age" appears as a substring
          "age *" = "deny";
          "*age *" = "ask";

          # git: ask before committing; deny push entirely to avoid
          # unintended remote writes
          "git commit *" = "ask";
          "git push *" = "deny";

          # SSH: allow local key management tools (no remote access involved)
          "ssh-keygen *" = "allow";
          "ssh-add *" = "allow";
          "ssh-agent *" = "allow";

          # SSH: ask before any remote access or file transfer over SSH
          "ssh *" = "ask";
          "scp *" = "ask";
          "sftp *" = "ask";
          # Only gate remote rsync (contains user@host: or host: syntax)
          "rsync *@*:*" = "ask";
          "rsync * *:*" = "ask";

          # IaC: deny destroy operations; ask for all other state-mutating
          # commands across terraform, tofu, and tf wrappers
          "*terraform destroy*" = "deny";
          "*terraform *" = "ask";
          "*tofu destroy*" = "deny";
          "*tofu *" = "ask";
          "*tf destroy*" = "deny";
          "*tf *" = "ask";
        };

        mcp = {
          k8s = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go" ];
          };

          nix = {
            type = "local";
            command = [ "${mcp-nixos}/bin/mcp-nixos" ];
          };

          opentofu = {
            type = "local";
            enabled = false;
            command = [ "${opentofu-mcp-server}/bin/opentofu-mcp-server" ];
          };

          terraform = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server" ];
          };

          context7 = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
          };

          sequential-thinking = {
            type = "local";
            enabled = false;
            command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
          };

          "context-mode" = {
            type = "local";
            command = [ "${context-mode}/bin/context-mode" ];
          };
        };

        # Load the context-mode TypeScript plugin for hook-based routing enforcement,
        # session continuity on compaction, and output compression. The plugin runs
        # inside OpenCode's bun process, so bun:sqlite is used (no native addon needed).
        plugin = [ "${context-mode}/lib/context-mode" ];
      };

      tui = {
        theme = "gruvbox";
        keybinds = {
          session_export = "none";
          session_share = "none";
          session_unshare = "none";
          terminal_suspend = "none";
          messages_first = "ctrl+home";
          messages_last = "ctrl+end";
        };
      };

      context = baseContext + cfg.extraContext;

      skills = defaultSkills // cfg.extraSkills;
    };
  };
}
