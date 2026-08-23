{
  config,
  lib,
  pkgs,
  ...
}:
let
  homeDns = lib.concatStringsSep " " config.module.variables.dnsServers;
  fallbackDns = lib.concatStringsSep " " config.module.variables.fallbackDns;
  homeSsidFile = "/var/run/agenix/home-ssid";
  wifiService = builtins.head config.module.variables.knownNetworkServices;
  script = pkgs.writeShellScript "dns-switcher" ''
    STATE_FILE=/tmp/dns-switcher-last-ssid
    rm -f "$STATE_FILE"

    while true; do
      WIFI_DEV=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
      SSID=$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null | awk '{print $NF}')
      HOME_SSID=$(cat ${lib.escapeShellArg homeSsidFile})
      LAST=$(cat "$STATE_FILE" 2>/dev/null || echo "")

      if [ "$SSID" != "$LAST" ]; then
        if [ "$SSID" = "$HOME_SSID" ]; then
          networksetup -setdnsservers ${lib.escapeShellArg wifiService} ${homeDns}
        else
          networksetup -setdnsservers ${lib.escapeShellArg wifiService} ${fallbackDns}
        fi
        echo "$SSID" > "$STATE_FILE"
      fi

      sleep 5
    done
  '';
in
{
  launchd.daemons.dns-switcher = {
    serviceConfig = {
      ProgramArguments = [ "${script}" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/dns-switcher.log";
      StandardErrorPath = "/var/log/dns-switcher.log";
    };
  };
}
