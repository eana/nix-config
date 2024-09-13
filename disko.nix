{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
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
                # settings = {
                #   allowDiscards = true;
                #   keyFile = "/tmp/secret.key";
                # };
                # additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [
                        "rw"
                        "noatime"
                        "discard=async"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "rw"
                        "noatime"
                        "discard=async"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "rw"
                        "noatime"
                        "discard=async"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                      ];
                    };
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = [
                        "rw"
                        "noatime"
                        "discard=async"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                      ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "rw"
                        "noatime"
                        "discard=async"
                        "compress-force=zstd:1"
                        "space_cache=v2"
                        "commit=120"
                      ];
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
