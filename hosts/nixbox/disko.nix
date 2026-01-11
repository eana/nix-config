let
  btrfsBaseOpts = [
    "rw"
    "noatime"
    "discard=async"
    "space_cache=v2"
    "commit=120"
  ];

  btrfsCompress = [ "compress=zstd:1" ];

  btrfsCompressForce = [ "compress-force=zstd:1" ];
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "nixos";
                # disable settings.keyFile if you want to use interactive password entry
                # passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  # keyFile = "/tmp/secret.key";
                };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = btrfsBaseOpts ++ btrfsCompress;
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = btrfsBaseOpts ++ btrfsCompress;
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = btrfsBaseOpts ++ btrfsCompressForce;
                    };
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = btrfsBaseOpts ++ btrfsCompress;
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = btrfsBaseOpts ++ btrfsCompress;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
