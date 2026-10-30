---
generated_commit: 06cd74bc677d19a9e44814ed8572eab31dbcd7f9
generated_at: 2026-10-30T09:19:38Z
source_paths:
  - hosts
---

# hosts

Per-host assembly. Each host directory has a `default.nix` that lists its modules.
`hosts/shared/` is the common base for nixbox and macbox; nasbox does not use it.

## Shared tree (`hosts/shared/`)

`hosts/shared/default.nix` imports six files:

- `home-manager/default.nix` - `backupFileExtension = "backup"`, `useGlobalPkgs`,
  `useUserPackages`.
- `nix/default.nix` - imports `modules/common/nix-cache.nix`; `trusted-users` = root and
  `userName`, plus `@wheel` on Linux; `extraOptions` from `dev/nix.conf`; GC on Darwin
  `interval.Hour = 3` with `--delete-older-than 14d`, on Linux `dates = "12:12"` with no age
  option; `allowUnfree`. The `doCheckByDefault` hack was dropped here, so package tests run
  again on nixbox and macbox; nasbox still keeps its own copy (see below).
- `secrets.nix` - the agenix secrets (see below).
- `system/environment.nix` - `EDITOR = nvim`.
- `system/packages.nix` - a list of 10 fonts.
- `variables.nix` - declares `module.variables` with defaults `dnsServers = [ "192.168.0.145" ]`,
  `fallbackDns = [ "1.1.1.1" "9.9.9.9" ]`, `userName = "jonas"`,
  `timeZone = "Europe/Stockholm"`, `knownNetworkServices = [ "Wi-Fi" ]`; sets `time.timeZone`.

Not imported by `shared/default.nix`; each host adds its own:

- `shared/system/linux.nix` - NetworkManager, passwordless `nixos-rebuild` via
  `security.sudo.extraRules`.
- `shared/system/darwin.nix` - `networking.knownNetworkServices` from variables,
  passwordless `darwin-rebuild` via `security.sudo.extraConfig`.

## nixbox (NixOS, x86_64-linux)

`default.nix` imports `shared/default`, `shared/system/linux`, `disko.nix`, `gdm.nix`,
`hardware-configuration.nix` (generated), `home-manager`, `nix`, the ten `system/*.nix`
files, and `modules/linux/libvirt/default.nix`. It sets `hardware.nvidiaPrime.enable`,
US console keymap, `en_US.UTF-8`, `i18n.inputMethod.enabled = null`,
`module.libvirt = { enable = true; user = "jonas"; gui.enable = true; platformCpu = "intel"; }`
and `system.stateVersion = "24.05"`.

- `nix/default.nix` - `nixpkgs.hostPlatform = "x86_64-linux"`.
- `disko.nix` - `/dev/nvme0n1` GPT: ESP (`EF00`, vfat, `/boot`, `umask=0077`) and LUKS
  `nixos` (`allowDiscards`) holding btrfs (`-f`) subvolumes `@` (`/`), `@home`, `@nix`,
  `@snapshots` (`/.snapshots`), `@log` (`/var/log`). Mount options
  `rw,noatime,discard=async,space_cache=v2,commit=120`, `compress=zstd:1`; `@nix` uses
  `compress-force=zstd:1`.
- `gdm.nix` - a `systemd.tmpfiles` `L+` rule linking `monitors.xml` to
  `/run/gdm/.config/monitors.xml`.
- `system/boot.nix` - btrfs support, `linuxPackages_latest`, systemd-boot,
  `efi.canTouchEfiVariables`.
- `system/networking.nix` - firewall off, hostname `nixbox`, IPv6 off, NetworkManager with two
  dispatcher scripts: wifi/wired exclusivity, and `per-ssid-dns` (wifi only, on `up` or
  `connectivity-change`; reads `/run/agenix/home-ssid`, exits 1 if unreadable; sets
  `ipv4.dns` from `dnsServers` or `fallbackDns` with `ipv4.ignore-auto-dns yes`).
- `system/nvidia.nix` - option `hardware.nvidiaPrime.enable`; Prime with
  `nvidiaBusId = "PCI:1:0:0"`, `intelBusId = "PCI:0:2:0"`, `open = false`, modesetting,
  power management, `videoDrivers = [ "nvidia" ]`. The bus ID comment shows a plain
  `$ nix-shell -p pciutils ...` command instead of a prompt glyph.
- `system/services.nix` - weekly fstrim, avahi (nssmdns4, openFirewall), blueman, GDM with
  `defaultSession = "sway"`, GNOME desktop manager, printing (`canon-cups-ufr2`), libinput,
  dbus, openssh, logind `HandleLidSwitchExternalPower = "ignore"`, gcr-ssh-agent off,
  journald size limits 100M.
- `system/packages.nix` - programs: sway, ydotool, zsh, `ssh.startAgent`,
  `nix-index-database.comma`; `niri` and `dms-shell` disabled; packages blueman, curl,
  gparted, zsh-powerlevel10k; `fonts.enableDefaultPackages`.
- `system/environment.nix` - `MOZ_ENABLE_WAYLAND = 1`, `SSH_ASKPASS` forced empty,
  `wordlist.enable`, and `/etc/security/faillock.conf` with `deny = 0`.
- `system/security.nix` - PAM service `swaylock`, `fprintAuth = false`.
- `system/audio.nix` - blacklists `snd_soc_avs`, all firmware, rtkit, pipewire with pulse.
- `system/hardware.nix` - bluetooth profiles, graphics.
- `system/virtualization.nix` - `nix-ld` with graphics libraries, `zramSwap` 50 percent.
- `home-manager/default.nix` - sets `_module.args.sshSecretsPath` and `atuinSecretsPath`;
  imports `home/users/jonas/linux.nix`, the nixvim HM module, all `modules/common`, and all
  `modules/linux` except `libvirt`; `extraSpecialArgs = { inputs; nixvimInput; }`; user
  `jonas` (`isNormalUser`, groups video, wheel, ydotool); `users.defaultUserShell = pkgs.zsh`.

## macbox (nix-darwin, aarch64-darwin)

`default.nix` imports `shared/default`, `shared/system/darwin`, `home-manager`, `nix` and
`system/{defaults,dns-switcher,environment,homebrew,packages}`. It sets
`primaryUser = "jonas"`, `configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null`
and `system.stateVersion = 6`.

- `nix/default.nix` - `nixpkgs.hostPlatform = "aarch64-darwin"`,
  `home-manager.useGlobalPkgs = true` (also set in the shared tree).
- `system/defaults.nix` - `system.keyboard` remap plus `system.defaults` for
  NSGlobalDomain, dock, finder, trackpad, loginwindow, screensaver, menu clock,
  ActivityMonitor, `LSQuarantine = false`, no automatic macOS updates, WindowManager,
  screencapture and spaces.
- `system/dns-switcher.nix` - launchd daemon (`KeepAlive`, log `/var/log/dns-switcher.log`)
  running a shell loop every 5 seconds. It detects the home network by gateway MAC (secret
  `home-gateway-mac`, with legacy SSID fallback) and sets DNS on the first
  `knownNetworkServices` entry with `networksetup`, re-pinning on drift. The MAC is masked in
  logs. Two `HACK` comments: `wait4path /nix/store` (APFS volume mount race) and the macOS
  26 SSID removal.
- `system/environment.nix` - `pathsToLink = [ "/Applications" ]` and an activation script
  aliasing apps into `/Applications/Nix Apps` with `mkalias`. System apps are collected with
  `find -type l` over the `buildEnv` (they are symlinks); Home Manager app bundles are
  instead scanned as `~/Applications/Home Manager Apps/*.app` because home-manager
  materializes them as real directories. A `HACK`/`TODO` comment marks that hand-rolled
  scan for removal once nix-darwin or home-manager provides an equivalent alias farm.
- `system/homebrew.nix` - nix-homebrew (`user = "jonas"`, `mutableTaps = false`, taps pinned
  from the `homebrew-core`, `homebrew-cask`, `nikitabobko-tap` inputs) and homebrew with casks
  aerospace, firefox, google-chrome, karabiner-elements, markedit, protonvpn, vlc, xnviewmp;
  `masApps.Bitwarden`; only `nikitabobko/tap` is trusted. `onActivation.cleanup` is
  `"uninstall"`, not `"zap"`: `zap` needs Full Disk Access that the root-chain
  `sudo --user=jonas ... brew bundle` cannot hold, so it aborted mid-uninstall and left
  Caskroom receipts. `uninstall` drops the bundle and receipt but keeps user data; a
  `HACK`/`TODO` says to restore `zap` if brew ever runs outside the root chain.
- `system/packages.nix` - home-manager, m-cli, mkalias, nightlight, zsh-powerlevel10k.
- `home-manager/default.nix` - sets the two agenix `_module.args`; imports
  `home/users/jonas/darwin.nix`, nixvim, `modules/darwin/aerospace`, `./file-associations.nix`,
  `./karabiner.nix`, `./nightlight.nix` and all `modules/common`; `home.stateVersion = "26.05"`,
  `home.enableNixpkgsReleaseCheck = false`.
- `home-manager/file-associations.nix` - adds `pkgs.duti` and writes `~/.duti.conf` binding
  XnViewMP (`com.xnview.XnView`) as default handler for image UTIs (`public.jpeg`,
  `public.png`, `public.tiff`, `com.compuserve.gif`, `com.microsoft.bmp`, `public.heic`,
  `public.webp`, `public.avif`, `public.jpeg-2000`, `com.truevision.tga-image`). Bindings are
  by UTI so extension casing never diverges. A `writeBoundary`-after activation script runs
  `duti ~/.duti.conf`.
- `home-manager/karabiner.nix` - writes `~/.config/karabiner/karabiner.json` (AltGr chords,
  Windows-style Home/End, Right Option / Right Control swap, `ansi` keyboard type).
- `home-manager/nightlight.nix` - options `eana.nightShift.{start,end}` (defaults `19:00` and
  `9:00`) and a launchd agent `com.eana.night-shift`.

## nasbox (Synology NAS, standalone Home Manager)

`default.nix` imports only `./home-manager` and `./nix` and sets
`home.stateVersion = "26.05"`. No `hosts/shared`, no agenix.

- `nix/default.nix` - imports `modules/common/nix-cache.nix`; `nix.package = pkgs.nix`;
  `trusted-users = [ "root" ]`; `extraOptions` from `dev/nix.conf`; `allowUnfree`;
  `doCheckByDefault = false` (marked TEMPORARY/TODO, so package tests are skipped here
  only; the shared tree no longer sets it).
- `home-manager/default.nix` - imports `home/users/root/ds920p.nix`, nixvim and all
  `modules/common` (via a locally imported `lib.nix`); `home.username = "root"`,
  `home.homeDirectory = "/root"`.

## Secrets (agenix)

`hosts/shared/secrets.nix` declares `home-ssid`, `home-gateway-mac`, `ssh-hosts` and `atuin`,
each `file = ../../secrets/<name>.age`, `mode = "0400"`, owned by `module.variables.userName`,
group `staff` on Darwin and `users` on Linux.

- Only nixbox and macbox import it.
- Home Manager gets `config.age.secrets.ssh-hosts.path` and `config.age.secrets.atuin.path`
  as `_module.args.sshSecretsPath` / `atuinSecretsPath`.
- System scripts read `/run/agenix/home-ssid` (nixbox) and
  `/var/run/agenix/{home-gateway-mac,home-ssid}` (macbox).
- Because the declaration is shared, nixbox also decrypts `home-gateway-mac`, but nothing on
  nixbox reads it.

## Related pages

- [configurations](../configurations/index.md)
- [home](../home/index.md)
- [modules/common](../modules-common/index.md), [modules/linux](../modules-linux/index.md),
  [modules/darwin](../modules-darwin/index.md)
