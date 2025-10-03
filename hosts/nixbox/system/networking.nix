{
  lib,
  pkgs,
  ...
}:

{
  networking = {
    firewall.enable = false;
    hostName = "nixbox";
    enableIPv6 = false;
    networkmanager = {
      enable = true;
      dispatcherScripts = [
        {
          type = "basic";
          source = pkgs.writeText "wifi-wired-exclusive" ''
            export LC_ALL=C
            PATH=${lib.makeBinPath [ pkgs.networkmanager ]}:$PATH

            enable_disable_wifi ()
            {
                result=$(nmcli dev | grep "ethernet" | grep -w "connected")
                if [ -n "$result" ]; then
                    nmcli radio wifi off
                else
                    nmcli radio wifi on
                fi
            }

            if [ "$2" = "up" ]; then
                enable_disable_wifi
            fi

            if [ "$2" = "down" ]; then
                enable_disable_wifi
            fi
          '';
        }
      ];
    };
  };
}
