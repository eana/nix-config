______________________________________________________________________

title: Home Users
generated_commit: b9ee706915c5dfd42b98ba9de6c553e1df8a2c8d
source_paths:

- home/

______________________________________________________________________

# Home Users

Per-user Home Manager config layer. Import chain is layered: platform file ->
`common.nix` -> `../shared.nix`. `shared.nix` holds the baseline every user
inherits; platform files add host-specific behavior.

## Users

| User | Hosts | Files |
| --- | --- | --- |
| jonas | macbox (darwin), nixbox (linux) | `common.nix`, `darwin.nix`, `linux.nix` |
| root | nasbox (DS920+) | `common.nix`, `ds920p.nix` |

## home/users/shared.nix

Baseline all users inherit:

- Programs: direnv + nix-direnv, nh (flake = `/etc/nixos`, weekly clean),
  ssh-agent service.
- Packages: axel, tree, unzip, fzf, lazygit, tig, fastfetch.
- `sessionVariables.LESS = "-iXFR"`, `stateVersion = "26.05"`.
- `module.*` defaults: git (ghq root `~/repos`), gpg-agent, nixvim
  (wrapColumn 120), tmux, zsh.

## jonas

- `common.nix`: base packages (fd, ripgrep, jaq, age, telegram-desktop, ...),
  session vars, `custom.theme = "gruvbox"`. Modules: atuin (sync to
  `https://atuin.eana.win`, `credentialsFile = atuinSecretsPath`), kitty (macOS
  keybindings for Karabiner/AeroSpace interop, lines 75-88), opencode (playwright,
  garmin, skills `["social"]`), podman, ssh-client (secretsFile = `sshSecretsPath`,
  KexAlgorithms hardening). Optional args `sshSecretsPath ? null, atuinSecretsPath ? null` (lines 3-4) are plumbed by host configs.
- `darwin.nix`: aerospace (modifier = cmd), local ollama server with Apple Silicon
  tuning (flash attention, q8_0 KV), packages cmake/mas/maccy/iproute2mac/procps.
- `linux.nix`: systemd.user services (copyq, telegram, bluetooth-applet,
  swaynag-battery) wanted by `sway-session.target`; dconf/gtk Yaru theme; ollama CLI
  only pointing at `macbox.local:11434` (split documented at
  `jonas/common.nix:127-141`); local `aws-export-profile` mkDerivation (lines 11-24);
  modules sway, waybar, foot, fuzzel, kanshi, mhalo, mpv, openra, avizo, gammastep.

## root

- `common.nix`: passthrough importing `../shared.nix`.
- `ds920p.nix`: the real config for nasbox - network admin packages (iftop, iotop,
  nethogs, iperf, zmap, sysstat, dnsutils), git identity with
  `sshKey ~/.ssh/id_ed25519_git` and `pathPatterns ~/repos/**`.
- HACK (lines 36-39): DSM has no working root `systemd --user`, so agenix/atuin
  login units never start. `home.activation.atuinLogin` runs during HM activation:
  pins `atuin.eana.win` in `/etc/hosts`, runs `age --decrypt` on
  `secrets/atuin.age` with `~/.ssh/id_ed25519`, conditionally logs in. TODO:
  restore agenix flow when DSM gets `systemd --user`.

## Key files

| File | Role |
| --- | --- |
| `home/users/shared.nix` | Baseline for all users |
| `home/users/jonas/common.nix` | jonas base, imports shared |
| `home/users/jonas/darwin.nix` | macbox layer |
| `home/users/jonas/linux.nix` | nixbox layer (sway) |
| `home/users/root/common.nix` | Passthrough to shared |
| `home/users/root/ds920p.nix` | nasbox root config, activation HACK |

## Notable patterns

- Layered imports: platform -> common -> shared.
- Secrets reach users via optional function args + `_module.args` plumbing
  (`jonas/common.nix:3-4`).
- HACK markers include why and removal condition (`ds920p.nix:36-39`).

## Related pages

- [hosts](../hosts/index.md)
- [modules-common](../modules-common/index.md)
