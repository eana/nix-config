______________________________________________________________________

title: Secrets
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- secrets.nix
- secrets/
- hosts/shared/secrets.nix

______________________________________________________________________

# Secrets

agenix-based declarative secret management. Encrypted `.age` files under
`secrets/`, recipients declared in `secrets.nix`, decryption wired via
`age.secrets` module options. No secret values are documented here.

## Key files

| File | Role |
| --- | --- |
| `secrets.nix` | Recipient registry (10 ed25519 keys) |
| `secrets/*.age` | 4 encrypted blobs (never opened directly) |
| `hosts/shared/secrets.nix` | `age.secrets` declarations (paths, modes, owners) |
| `hosts/{nixbox,macbox}/home-manager/default.nix` | Path plumbing into `_module.args` |

## Recipients and secrets

`secrets.nix` declares user keys `jonas-{macbox,nasbox,newbox,nixbox,oldbox}` and
host keys `{macbox,nasbox,newbox,nixbox,oldbox}`. All four secrets encrypt to
`allUsers ++ allSystems`:

- `home-ssid.age`
- `home-gateway-mac.age`
- `ssh-hosts.age`
- `atuin.age`

## Decryption wiring

1. `hosts/shared/secrets.nix:2-27` declares `age.secrets` for all four: mode 0400,
   owner `config.module.variables.userName`, group staff (Darwin) or users (Linux).
   Imported via `hosts/shared/default.nix:6`.
1. Host HM wiring sets `_module.args.sshSecretsPath` /
   `_module.args.atuinSecretsPath` to `config.age.secrets.{ssh-hosts,atuin}.path`
   (`hosts/nixbox/home-manager/default.nix:12-13`,
   `hosts/macbox/home-manager/default.nix:11-12`).
1. `home/users/jonas/common.nix:3-4` declares the optional args; consumed at
   `:61` (atuin `credentialsFile`) and `:119` (ssh `secretsFile`).

## Exceptions

- **nasbox**: `hosts/nasbox/default.nix:2-7` imports no `../shared`, so no agenix.
  `home/users/root/ds920p.nix:40-55` HACK (DSM lacks root `systemd --user`):
  `home.activation.atuinLogin` runs raw `age --decrypt -i ~/.ssh/id_ed25519` on
  `secrets/atuin.age`. TODO: restore agenix flow when DSM has `systemd --user`.
- **macbox**: decrypts with `/etc/ssh/ssh_host_ed25519_key`. After a macOS reinstall
  the key changes: update `secrets.nix` and re-encrypt BEFORE `darwin-rebuild switch`,
  or decryption fails silently (README.md:66-95).

## Related pages

- [hosts](../hosts/index.md)
- [home](../home/index.md)
