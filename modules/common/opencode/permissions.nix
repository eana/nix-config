{
  enableSnip ? false,
}:
let
  inherit (builtins) attrNames listToAttrs;
  baseRules = {
    # age: deny direct invocations to prevent secret exposure; ask on
    # incidental matches where "age" appears as a substring
    "age *" = "deny";
    "*age *" = "ask";

    # sops: deny direct invocations to prevent secret exposure; ask on
    # incidental matches where "sops" appears as a substring
    "sops *" = "deny";
    "*sops *" = "ask";

    # agenix / ragenix: deny invocations to prevent
    # accidental secret editing or rekeying
    "*agenix *" = "deny";
    "*ragenix *" = "deny";

    # Privilege escalation: no legitimate AI use case
    "*sudo *" = "deny";
    "*doas *" = "deny";

    # git: ask before committing; deny push entirely to avoid
    # unintended remote writes
    "*git commit *" = "ask";
    "*git push *" = "deny";

    # SSH: allow local key management tools (no remote access involved)
    "*ssh-keygen *" = "allow";
    "*ssh-add *" = "allow";
    "*ssh-agent *" = "allow";

    # SSH: ask before any remote access or file transfer over SSH
    "*ssh *" = "ask";
    "*scp *" = "ask";
    "*sftp *" = "ask";
    # Only gate remote rsync (contains user@host: or host: syntax)
    "*rsync *@*:*" = "ask";
    "*rsync * *:*" = "ask";

    # IaC: deny destroy operations; ask for all other state-mutating
    # commands across terraform, tofu, and tf wrappers
    "*terraform destroy*" = "deny";
    "*terraform *" = "ask";
    "*tofu destroy*" = "deny";
    "*tofu *" = "ask";
    "*tf destroy*" = "deny";
    "*tf *" = "ask";

    # Nix rebuild and system apply: ask before applying configuration
    # changes via any supported tool
    "*darwin-rebuild*" = "ask";
    "*nixos-rebuild*" = "ask";
    "*nh *" = "ask";
    "*home-manager *" = "ask";

    # Mutable installs: deny commands that side-step the declarative flake
    "*nix profile *" = "deny";
    "*nix-env *" = "deny";

    # Service management: deny direct daemon/service manipulation
    "*launchctl *" = "deny";
    "*systemctl *" = "deny";

    # Containers: ask before running arbitrary containers
    "*docker *" = "ask";
    "*podman *" = "ask";

    # Kubernetes: ask before mutating cluster state
    "*kubectl *" = "ask";

    # Out-of-band package managers: ask before installing outside Nix
    "*brew *" = "ask";
    "*pip install*" = "ask";
    "*npm install -g*" = "ask";

    # Filesystem-wide scans: deny walking / or /nix/store, which is slow,
    # produces huge output and can hit network mounts
    "*find /" = "deny";
    "*find / *" = "deny";
    "*find /nix/store*" = "deny";
    "*fd * /" = "deny";
    "*fd * / *" = "deny";
    "*fd * /nix/store*" = "deny";
    "*rg * /" = "deny";
    "*rg * / *" = "deny";
    "*rg * /nix/store*" = "deny";
    "*grep -r* /" = "deny";
    "*grep -r* / *" = "deny";
    "*du * /" = "deny";
    "*du /" = "deny";
    "locate *" = "ask";

    # Destructive recursive ops on root or home
    "*rm -rf /" = "deny";
    "*rm -rf / *" = "deny";
    "*rm -rf ~*" = "deny";
    "*chmod -R * /" = "deny";
    "*chown -R * /" = "deny";
    "*dd *of=/dev/*" = "deny";
    "*mkfs*" = "deny";
  };

  snipRules =
    if enableSnip then
      listToAttrs (
        map (name: {
          name = "snip ${name}";
          value = baseRules.${name};
        }) (attrNames baseRules)
      )
    else
      { };
in
{
  permission.bash = baseRules // snipRules;
}
