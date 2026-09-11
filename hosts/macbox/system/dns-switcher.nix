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
  legacyHomeSsidFile = "/run/agenix/home-ssid";
  wifiService = builtins.head config.module.variables.knownNetworkServices;
  script = pkgs.writeShellScript "dns-switcher" ''
    PATH="/usr/sbin:/usr/bin:/bin:/sbin"
    STATE_FILE=/tmp/dns-switcher-last-ssid
    ITERATION=0

    log() {
      local message="$1"
      local ts
      ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      printf "%s dns-switcher[%s] %s\n" "$ts" "$$" "$message" >&2
      logger -t dns-switcher -- "$message" || true
    }

    run_and_log() {
      local label="$1"
      shift
      local output
      if output=$("$@" 2>&1); then
        if [ -n "$output" ]; then
          log "$label ok: $output"
        else
          log "$label ok"
        fi
        return 0
      fi

      local rc=$?
      if [ -n "$output" ]; then
        log "$label failed rc=$rc: $output"
      else
        log "$label failed rc=$rc"
      fi
      return $rc
    }

    rm -f "$STATE_FILE"
    log "start wifiService='${wifiService}' homeDns='${homeDns}' fallbackDns='${fallbackDns}'"

    while true; do
      ITERATION=$((ITERATION + 1))

      if ! networksetup -listallnetworkservices | grep -Fxq ${lib.escapeShellArg wifiService}; then
        logger -t dns-switcher "network service ${wifiService} not found; skipping"
        sleep 5
        continue
      fi

      WIFI_DEV=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
      if [ -z "$WIFI_DEV" ]; then
        log "wifi device not found from networksetup output"
        sleep 5
        continue
      fi

      SSID_LINE=$(networksetup -getairportnetwork "$WIFI_DEV" 2>/dev/null || true)
      case "$SSID_LINE" in
        "Current Wi-Fi Network: "*)
          SSID="''${SSID_LINE#Current Wi-Fi Network: }"
          ;;
        *)
          SSID=""
          ;;
      esac

      if [ -r ${lib.escapeShellArg homeSsidFile} ]; then
        HOME_SSID=$(cat ${lib.escapeShellArg homeSsidFile})
      elif [ -r ${lib.escapeShellArg legacyHomeSsidFile} ]; then
        HOME_SSID=$(cat ${lib.escapeShellArg legacyHomeSsidFile})
      else
        logger -t dns-switcher "home-ssid secret missing; skipping"
        sleep 5
        continue
      fi

      LAST=$(cat "$STATE_FILE" 2>/dev/null || echo "")
      if [ "$ITERATION" -eq 1 ] || [ $((ITERATION % 60)) -eq 0 ]; then
        CURRENT_DNS=$(networksetup -getdnsservers ${lib.escapeShellArg wifiService} 2>&1 || true)
        CURRENT_DNS_LINE=$(printf "%s" "$CURRENT_DNS" | tr '\n' ';')
        log "heartbeat iter=$ITERATION wifiDev='$WIFI_DEV' ssid='$SSID' homeSsid='$HOME_SSID' last='$LAST' dns='$CURRENT_DNS_LINE'"
      fi

      if [ "$SSID" != "$LAST" ]; then
        log "ssid transition old='$LAST' new='$SSID' home='$HOME_SSID'"
        if [ "$SSID" = "$HOME_SSID" ]; then
          if run_and_log "set home dns service=${wifiService} ssid='$SSID'" networksetup -setdnsservers ${lib.escapeShellArg wifiService} ${homeDns}; then
            CURRENT_DNS=$(networksetup -getdnsservers ${lib.escapeShellArg wifiService} 2>&1 || true)
            CURRENT_DNS_LINE=$(printf "%s" "$CURRENT_DNS" | tr '\n' ';')
            log "post-setdnsservers service=${wifiService} dns='$CURRENT_DNS_LINE'"
          fi
        else
          if run_and_log "set fallback dns service=${wifiService} ssid='$SSID'" networksetup -setdnsservers ${lib.escapeShellArg wifiService} ${fallbackDns}; then
            CURRENT_DNS=$(networksetup -getdnsservers ${lib.escapeShellArg wifiService} 2>&1 || true)
            CURRENT_DNS_LINE=$(printf "%s" "$CURRENT_DNS" | tr '\n' ';')
            log "post-setdnsservers service=${wifiService} dns='$CURRENT_DNS_LINE'"
          fi
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
