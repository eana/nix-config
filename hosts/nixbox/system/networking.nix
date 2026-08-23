{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeSsidFile = "/run/agenix/home-ssid";
in

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
        {
          type = "basic";
          source = pkgs.writeText "per-ssid-dns" ''
            export LC_ALL=C
            PATH=${
              lib.makeBinPath [
                pkgs.gawk
                pkgs.networkmanager
                pkgs.util-linux
              ]
            }:$PATH

            INTERFACE="$1"
            EVENT="$2"

            if [ "$EVENT" != "up" ] && [ "$EVENT" != "connectivity-change" ]; then
              exit 0
            fi

            IF_TYPE=$(nmcli -t -f DEVICE,TYPE dev | awk -F: -v iface="$INTERFACE" '$1==iface{print $2}')
            if [ "$IF_TYPE" != "wifi" ]; then
              exit 0
            fi

            CON=$(nmcli -t -f DEVICE,NAME con show --active | awk -F: -v iface="$INTERFACE" '$1==iface{print $2}')
            if [ -z "$CON" ]; then
              exit 0
            fi

            SSID=$(nmcli -t -f active,ssid dev wifi | awk -F: '/^yes/{print $2}')
            HOME_SSID=$(cat ${lib.escapeShellArg homeSsidFile} 2>/dev/null)
            if [ -z "$HOME_SSID" ]; then
              logger -t per-ssid-dns "home-ssid secret unreadable; skip dns update"
              exit 1
            fi

            if [ "$SSID" = "$HOME_SSID" ]; then
              DNS="${lib.concatStringsSep " " config.module.variables.dnsServers}"
            else
              DNS="${lib.concatStringsSep " " config.module.variables.fallbackDns}"
            fi

            nmcli con mod "$CON" ipv4.dns "$DNS"
            nmcli con mod "$CON" ipv4.ignore-auto-dns yes
            logger -t per-ssid-dns "iface=$INTERFACE con=$CON ssid=$SSID dns=$DNS"
          '';
        }
      ];
    };
  };
}
