{
  config,
  lib,
  pkgs,
  ...
}:
let
  homeDns = lib.concatStringsSep " " config.module.variables.dnsServers;
  fallbackDns = lib.concatStringsSep " " config.module.variables.fallbackDns;
  homeGatewayMacFile = "/var/run/agenix/home-gateway-mac";
  homeSsidFile = "/var/run/agenix/home-ssid";
  wifiService = builtins.head config.module.variables.knownNetworkServices;
  script = pkgs.writeShellScript "dns-switcher" ''
    PATH="/usr/sbin:/usr/bin:/bin:/sbin"
    STATE_FILE=/tmp/dns-switcher-last-gateway-mac
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

    # HACK: home-network detection cannot use SSID — macOS 26+ removed
    #   `networksetup -getairportnetwork` and redacts SSID in `wdutil info`
    #   and `system_profiler` output. Gateway MAC stays readable (root-gated,
    #   and this daemon runs as root). The home-ssid branch below is kept only
    #   for fallback on older macOS.
    #   TODO: drop home-ssid branch once no host runs macOS < 26.
    normalize_mac() {
      local mac
      mac=$(printf '%s\n' "$1" | awk -F: '
        NF == 6 {
          ok = 1
          padded = ""
          for (i = 1; i <= NF; i++) {
            if ($i !~ /^[0-9a-fA-F]+$/) { ok = 0; break }
            if (length($i) == 1) $i = "0" $i
            padded = padded (i == 1 ? "" : ":") tolower($i)
          }
          if (ok) print padded
        }
      ')
      printf '%s' "$mac"
    }

    # Gateway MAC is a home-network fingerprint; never log it in full.
    mask_mac() {
      local m="$1"
      case "$m" in
        ??:??:??:??:*)
          printf '%s\n' "$m" | awk '{ print "xx:xx:" substr($0, length($0) - 4) }'
          return
          ;;
      esac
      printf '%s' "$m"
    }

    get_gateway_mac() {
      local gw mac
      gw=$(netstat -rn -f inet | awk '$1=="default"{print $2; exit}')
      if [ -z "$gw" ]; then
        return 1
      fi
      # warm the ARP cache so arp -n can report the gateway MAC
      ping -c 1 "$gw" >/dev/null 2>&1 || true
      mac=$(arp -n "$gw" | awk '{print $4; exit}')
      normalize_mac "$mac"
    }

    # Legacy SSID source for macOS < 26 (returns empty today).
    get_current_ssid() {
      local wifi_dev ssid
      wifi_dev=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
      ssid=$(wdutil info 2>/dev/null | awk -F':' '/[Ss][Ss][Ii][Dd]/{v=$0; sub(/^[^:]*:[[:space:]]*/, "", v); print v; exit}' | tr -d '\r')
      if [ -z "$ssid" ]; then
        ssid=$(networksetup -getairportnetwork "$wifi_dev" 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')
      fi
      printf '%s' "$ssid"
    }

    # Set DNS on $3 only when it drifted from the expected value; operations
    # like DHCP lease renewal silently wipe networksetup DNS settings.
    ensure_dns() {
      local label="$1" expected="$2" service="$3" current exp
      current=$(networksetup -getdnsservers "$service" 2>&1 || true)
      current=$(printf "%s" "$current" | tr '\n' ' ' | sed 's/[[:space:]]*$//')
      exp=$(printf '%s' "$expected" | sed 's/[[:space:]]*$//')
      if [ "$current" = "$exp" ]; then
        return 0
      fi
      set -- $expected
      run_and_log "$label service=$service expected='$exp'" networksetup -setdnsservers "$service" "$@"
    }

    rm -f "$STATE_FILE"
    log "start wifiService='${wifiService}' homeDns='${homeDns}' fallbackDns='${fallbackDns}'"

    while true; do
      ITERATION=$((ITERATION + 1))

      if ! networksetup -listallnetworkservices | grep -Fxq ${lib.escapeShellArg wifiService}; then
        log "network service ${wifiService} not found; skipping"
        sleep 5
        continue
      fi

      GW=$(netstat -rn -f inet | awk '$1=="default"{print $2; exit}')
      if [ -z "$GW" ]; then
        log "no default ipv4 route; deferring dns update"
        sleep 5
        continue
      fi

      GW_MAC=$(get_gateway_mac)
      HOME_GW_MAC=$(cat ${lib.escapeShellArg homeGatewayMacFile} 2>/dev/null || true)
      HOME_GW_MAC=$(normalize_mac "$HOME_GW_MAC")
      IS_HOME=0
      [ -n "$HOME_GW_MAC" ] && [ "$GW_MAC" = "$HOME_GW_MAC" ] && IS_HOME=1

      # legacy fallback on macOS < 26: home SSID matches the home-ssid secret
      if [ "$IS_HOME" -eq 0 ] && [ -r ${lib.escapeShellArg homeSsidFile} ]; then
        HOME_SSID=$(cat ${lib.escapeShellArg homeSsidFile})
        SSID=$(get_current_ssid)
        log "gw '$(mask_mac "$GW_MAC")' != home '$(mask_mac "$HOME_GW_MAC")'; checking legacy ssid ssid='$SSID'"
        if [ "$SSID" = "$HOME_SSID" ]; then
          IS_HOME=1
        fi
      elif [ -z "$GW_MAC" ]; then
        log "gateway mac unknown for gw=$GW; deferring dns update"
        sleep 5
        continue
      fi

      LAST=$(cat "$STATE_FILE" 2>/dev/null || echo "")
      if [ "$ITERATION" -eq 1 ] || [ $((ITERATION % 60)) -eq 0 ]; then
        CURRENT_DNS=$(networksetup -getdnsservers ${lib.escapeShellArg wifiService} 2>&1 || true)
        CURRENT_DNS_LINE=$(printf "%s" "$CURRENT_DNS" | tr '\n' ';')
        log "heartbeat iter=$ITERATION gw='$GW' mac='$(mask_mac "$GW_MAC")' homeMacSecret='$([ -n "$HOME_GW_MAC" ] && echo present || echo missing)' isHome='$IS_HOME' last='$(mask_mac "$LAST")' dns='$CURRENT_DNS_LINE'"
      fi

      if [ "$GW_MAC" != "$LAST" ]; then
        log "gateway transition old='$(mask_mac "$LAST")' new='$(mask_mac "$GW_MAC")' home='$(mask_mac "$HOME_GW_MAC")' isHome='$IS_HOME'"
        if [ "$IS_HOME" -eq 1 ]; then
          ensure_dns "set home dns gw='$GW' mac='$(mask_mac "$GW_MAC")'" "${homeDns}" ${lib.escapeShellArg wifiService}
        else
          ensure_dns "set fallback dns gw='$GW' mac='$(mask_mac "$GW_MAC")'" "${fallbackDns}" ${lib.escapeShellArg wifiService}
        fi
        echo "$GW_MAC" > "$STATE_FILE"
      elif [ "$IS_HOME" -eq 1 ]; then
        # no gateway transition; re-pin home dns in case dhcp renewal wiped it
        ensure_dns "drift home dns mac='$(mask_mac "$GW_MAC")'" "${homeDns}" ${lib.escapeShellArg wifiService}
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
