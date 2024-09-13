# nixos

```shell
sudo nix --experimental-features "nix-command flakes" run nixpkgs#git clone https://github.com/eana/nixos
cd ./nixos/
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko disko.nix
sudo nixos-generate-config --no-filesystems --root /mnt --dir .
sudo nixos-install --flake .#nixbox
```
