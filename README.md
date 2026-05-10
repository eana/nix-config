# nixos

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

### MacOS

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
   agenix -r -i ~/.ssh/id_ed25519
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
