# nix-config

## Things to do

- [x] Handle ~/.ssh/config
- [x] Handle ~/.config/mpv
- [x] Multiuser config for git
- [x] Add [aws-export-profile](https://github.com/cytopia/aws-export-profile)

## How to install

### Linux

```shell
sudo nix --experimental-features "nix-command flakes" run nixpkgs#git clone https://github.com/eana/nix-config
cd ./nix-config
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko hosts/nixbox/disko.nix
sudo nixos-generate-config --no-filesystems --root /mnt --dir hosts/nixbox
sudo nixos-install --flake .#nixbox
```

### macOS

- Install `nix`

```shell
# Install nix
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

- Install `nix-darwin`

Create `flake.nix`:

```shell
sudo mkdir -vp /etc/nix-darwin
sudo chown -v $(id -nu):$(id -ng) /etc/nix-darwin
cd /etc/nix-darwin

# To use Nixpkgs unstable:
nix flake init -t nix-darwin/master

sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
sed -i '' "s/aarch64-darwin/x86_64-darwin/" flake.nix
```

Install `nix-darwin`:

```shell
sudo mv -v /etc/bashrc{,.before-nix-darwin}
sudo mv -v /etc/zshrc{,.before-nix-darwin}

sudo nix run --experimental-features "nix-command flakes" nix-darwin/master#darwin-rebuild -- switch
```

Use `nix-darwin`:

```shell
cd ~/repos/github.com/eana/nix-config
mkdir -vp "/Users/jonas/Applications/Home Manager Apps/"
sudo darwin-rebuild switch --flake .#macbox
```

#### Secrets (agenix) after a macOS reinstall

A macOS reinstall generates new SSH host keys. `agenix` uses `/etc/ssh/ssh_host_ed25519_key` to decrypt secrets at activation, so the secrets must be re-keyed before running `darwin-rebuild switch` or decryption will silently fail and `/run/agenix/` will be empty at runtime.

Steps:

1. Generate the ssh key on the new host:

   ```shell
   # On the newly created macOS host, generate the ssh key
   ssh-keygen -t ed25519 -b 4096
   ```

1. Retrieve the new host public key:

   ```shell
   # Retrieve the ssh user key
   ssh-keygen -y -f ~/.ssh/id_ed25519
   # Retrieve the ssh host key
   ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key
   ```

1. Update the `macbox` entries in `secrets.nix` with the output above.

1. On a host that can re-encrypt all secrets for the new key:

   ```shell
   find-src github.com/eana/nix-config
   nix run .#agenix -- -r -i ~/.ssh/id_ed25519
   ```

1. Commit the updated `secrets.nix` and re-encrypted `.age` files, then run
   `sudo darwin-rebuild switch --flake .#macbox`.

**If secrets are still missing after a successful switch**, it is a launchd registration timing issue — the `activate-agenix` daemon was not reloaded on the first boot. Fix it without a full rebuild:

```shell
sudo launchctl kickstart -k system/org.nixos.activate-agenix
ls -alh /run/agenix/
```

#### SSH host config after login (`~/.ssh/config.d/ssh-hosts`)

The `ssh-hosts` secret is decrypted by `activate-agenix` at boot and then copied to `~/.ssh/config.d/ssh-hosts` by the `org.nix-community.ssh-secret-provision` launchd agent. The agent uses `WatchPaths` on `/run/agenix/ssh-hosts` so it re-runs automatically once agenix writes the secret, regardless of boot ordering.

**If `~/.ssh/config.d/ssh-hosts` is missing after login**, check the agent log:

```shell
cat ~/Library/Logs/ssh-secret-provision.out.log
```

A line reading `Secrets file not found` means the agent ran before agenix finished. Kick the agent manually to recover without rebooting:

```shell
launchctl kickstart -k gui/$(id -u)/org.nix-community.ssh-secret-provision
```

### Synology NAS

1. Prepare the filesystem for Nix store

   Root volume doesn't have enough space. Need to put nix store on data volume and bind mount to `/nix`.

   See https://stackoverflow.com/a/34966233

   > On Linux, bind mounts can be used instead of symlink for this purpose (e.g., `mount -o bind /data/nix/store /nix/store`).

   On the NAS

   ```bash
   mkdir -p /nix /volume1/nix
   chmod 755 /nix /volume1/nix
   mount -o bind /volume1/nix /nix
   ```

1. Build installer

   On another Nix machine

   ```bash
   # Clone the installer repo
   git clone https://github.com/sini/synology-nix-installer.git

   # Build static binary
   nix build .#packages.x86_64-linux.nix-installer-static -L

   # Copy to NAS
   rsync -e 'ssh -p 6646 -l jonas' ./result/bin/nix-installer 192.168.0.145:~/
   ```

1. Install Nix

   On NAS again

   ```bash
   # Disable syscall filtering
   NIX_INSTALLER_EXTRA_CONF='filter-syscalls = false' ./nix-installer install
   ```

1. Verify installation and start daemon

   One of the patches applied to the Nix installer prevents the nix daemon from starting automatically. The DetSys installer supports systemd 220, but DSM7.2.7 uses systemd 219, which doesn't support the `--now` flag.

   ```bash
   systemctl start nix-daemon
   source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
   nix run nixpkgs#hello
   ```

1. Configure startup scripts

   System configuration in `/etc` resets on reboot, requiring startup tasks to be configured through the web interface. Create two user-defined scripts:

   ```text
   Control Panel -> Task Scheduler -> Create -> Triggered Task -> User-defined script
   ```

   - Make the `/nix` mount persistent

     - Task: Bind mount nix
     - User: root
     - Event: Boot-up
     - Pre-task: None
     - Script:

     ```bash
     mount -o bind /volume1/nix /nix
     ```

   - Auto start nix-daemon service

     - Task: Start nix daemon
     - User: root
     - Event: Boot-up
     - Pre-task: Bind mount nix
     - Script:

     ```bash
     systemctl start nix-daemon
     ```

#### Upgrade Nix on the system

```shell
nix config check
nix upgrade-nix --dry-run --verbose
nix upgrade-nix --verbose
```

The output should look like this:

```shell
$ nix config check
[PASS] PATH contains only one nix version.
[PASS] All profiles are gcroots.
[PASS] Client protocol matches store protocol.
[INFO] You are trusted by store uri: local://
$ nix upgrade-nix --dry-run --verbose
found Nix in "/root/.nix-profile/bin"
found profile "/nix/var/nix/profiles/per-user/root/profile"
upgrading Nix in profile "/nix/var/nix/profiles/per-user/root/profile"
querying latest Nix version...
warning: would upgrade to version 2.34.6
$ nix upgrade-nix --verbose
found Nix in "/root/.nix-profile/bin"
found profile "/nix/var/nix/profiles/per-user/root/profile"
upgrading Nix in profile "/nix/var/nix/profiles/per-user/root/profile"
querying latest Nix version...
downloading '/nix/store/q7f0d4m54yj98fcjmbkscw83j82fypnd-nix-2.34.6'......
copying path '/nix/store/l34zf9300cgydgsimmnxvjl9ivjn2yjc-busybox-1.36.1' from 'https://cache.nixos.org'...
...
...
...
copying path '/nix/store/q7f0d4m54yj98fcjmbkscw83j82fypnd-nix-2.34.6' from 'https://cache.nixos.org'...
verifying that '/nix/store/q7f0d4m54yj98fcjmbkscw83j82fypnd-nix-2.34.6' works......
installing '/nix/store/q7f0d4m54yj98fcjmbkscw83j82fypnd-nix-2.34.6' into profile "/nix/var/nix/profiles/per-user/root/profile"......
replacing old 'nix-2.31.1'
installing 'nix-2.34.6'
building '/nix/store/vls8vljgw13b9q7cmzw4z68zra9dsy9k-user-environment.drv'...
upgrade to version 2.34.6 done
```
