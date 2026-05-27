{
  permission.bash = {
    # age: deny direct invocations to prevent secret exposure; ask on
    # incidental matches where "age" appears as a substring
    "age *" = "deny";
    "*age *" = "ask";

    # sops: deny direct invocations to prevent secret exposure; ask on
    # incidental matches where "sops" appears as a substring
    "sops *" = "deny";
    "*sops *" = "ask";

    # agenix / ragenix: deny direct invocations to prevent
    # accidental secret editing or rekeying
    "agenix *" = "deny";
    "ragenix *" = "deny";

    # Privilege escalation: no legitimate AI use case
    "sudo *" = "deny";
    "doas *" = "deny";

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

    # Nix rebuild and mutable installs: deny all commands that apply
    # system configurations or side-step the declarative flake
    "*darwin-rebuild*" = "deny";
    "*nixos-rebuild*" = "deny";
    "nh *" = "deny";
    "nix profile *" = "deny";
    "nix-env *" = "deny";

    # Service management: deny direct daemon/service manipulation
    "launchctl *" = "deny";
    "systemctl *" = "deny";

    # Containers: ask before running arbitrary containers
    "docker *" = "ask";
    "podman *" = "ask";

    # Kubernetes: ask before mutating cluster state
    "kubectl *" = "ask";

    # Out-of-band package managers: ask before installing outside Nix
    "brew *" = "ask";
    "*pip install*" = "ask";
    "*npm install -g*" = "ask";
  };
}
