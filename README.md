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
cd ~/repos/nix-config
mkdir -vp "/Users/jonas/Applications/Home Manager Apps/"
sudo darwin-rebuild switch --flake .#macbox
```
