# Plex and qBittorrent share the same slow disk on shiro. Plex direct play can
# buffer even without transcoding when torrents create disk latency, so this
# helper watches Plex's local sessions API and temporarily lowers qBittorrent
# transfer limits only while Plex is actually playing or buffering.
{lib, pkgs, ...}: let
  # qBittorrent's config file stores speed limits in KiB/s, while the Web API
  # uses bytes/s. Keep both forms derived from these values so the declarative
  # baseline and runtime limiter cannot drift silently.
  normalDownloadLimitKiB = 14100;
  normalUploadLimitKiB = 13350;
  plexActiveDownloadLimitBytes = 1024 * 1024;
  plexActiveUploadLimitBytes = 100 * 1024;
  normalDownloadLimitBytes = normalDownloadLimitKiB * 1024;
  normalUploadLimitBytes = normalUploadLimitKiB * 1024;

  qbittorrentPlexLimiter = pkgs.writeShellApplication {
    name = "qbittorrent-plex-limiter";
    runtimeInputs = [pkgs.coreutils pkgs.curl pkgs.python3];
    text = ''
      mode="''${1:-monitor}"
      plex_preferences="/var/lib/plex/Plex Media Server/Preferences.xml"

      # qBittorrent's localhost WebUI auth is bypassed declaratively for this
      # host, so the limiter can use the local API without storing credentials.
      apply_limits() {
        local label="$1"
        local dl_limit="$2"
        local up_limit="$3"

        ${lib.getExe pkgs.curl} \
          --fail \
          --silent \
          --show-error \
          --max-time 10 \
          --retry 3 \
          --retry-delay 2 \
          --data-urlencode "json={\"dl_limit\":$dl_limit,\"up_limit\":$up_limit}" \
          http://localhost:8080/api/v2/app/setPreferences

        echo "Applied $label qBittorrent limits: download=$dl_limit B/s upload=$up_limit B/s"
      }

      # Compare against qBittorrent's actual current preferences rather than a
      # local state file. This stays correct if qBittorrent restarts, reloads its
      # config, or someone changes limits in the WebUI between timer runs.
      limits_already_applied() {
        local dl_limit="$1"
        local up_limit="$2"
        local preferences_json

        preferences_json="$(${lib.getExe pkgs.curl} \
          --fail \
          --silent \
          --show-error \
          --max-time 10 \
          http://localhost:8080/api/v2/app/preferences)"

        PREFERENCES_JSON="$preferences_json" ${lib.getExe pkgs.python3} -c '
      import json
      import os
      import sys

      expected_dl = int(sys.argv[1])
      expected_up = int(sys.argv[2])

      try:
          preferences = json.loads(os.environ["PREFERENCES_JSON"])
          current_dl = int(preferences.get("dl_limit", -1))
          current_up = int(preferences.get("up_limit", -1))
      except Exception:
          sys.exit(1)

      sys.exit(0 if (current_dl, current_up) == (expected_dl, expected_up) else 1)
      ' "$dl_limit" "$up_limit"
      }

      # Plex keeps its local API token in Preferences.xml. The token is read at
      # runtime from shiro's state and is never copied into Git or the Nix store.
      plex_is_active() {
        [ -r "$plex_preferences" ] || return 1

        ${lib.getExe pkgs.python3} - "$plex_preferences" <<'PY'
      import sys
      import urllib.parse
      import urllib.request
      import xml.etree.ElementTree as ET

      preferences = sys.argv[1]
      try:
          token = ET.parse(preferences).getroot().attrib.get("PlexOnlineToken", "")
      except Exception:
          sys.exit(1)

      if not token:
          sys.exit(1)

      url = "http://localhost:32400/status/sessions?X-Plex-Token=" + urllib.parse.quote(token)
      try:
          with urllib.request.urlopen(url, timeout=5) as response:
              root = ET.fromstring(response.read())
      except Exception:
          sys.exit(1)

      for session in root:
          player = session.find("Player")
          if player is not None and player.attrib.get("state") in {"playing", "buffering"}:
              sys.exit(0)

      sys.exit(1)
      PY
      }

      case "$mode" in
        monitor)
          if plex_is_active; then
            desired_state="plex-active"
            dl_limit=${toString plexActiveDownloadLimitBytes}
            up_limit=${toString plexActiveUploadLimitBytes}
          else
            desired_state="normal"
            dl_limit=${toString normalDownloadLimitBytes}
            up_limit=${toString normalUploadLimitBytes}
          fi

          if limits_already_applied "$dl_limit" "$up_limit"; then
            echo "qBittorrent limits already match $desired_state"
            exit 0
          fi

          apply_limits "$desired_state" "$dl_limit" "$up_limit"
          ;;
        plex-active)
          apply_limits "plex-active" ${toString plexActiveDownloadLimitBytes} ${toString plexActiveUploadLimitBytes}
          ;;
        normal)
          apply_limits "normal" ${toString normalDownloadLimitBytes} ${toString normalUploadLimitBytes}
          ;;
        *)
          echo "usage: qbittorrent-plex-limiter [monitor|plex-active|normal]" >&2
          exit 2
          ;;
      esac
    '';
  };
in {
  systemd.services.qbittorrent-plex-limiter = {
    description = "Limit qBittorrent while Plex is actively playing";
    # This service is a tiny polling controller, not a daemon. The timer invokes
    # it periodically, it checks Plex/qBittorrent once, applies limits only when
    # needed, then exits.
    after = ["qbittorrent.service"];
    wants = ["qbittorrent.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe qbittorrentPlexLimiter} monitor";
    };
  };

  systemd.timers.qbittorrent-plex-limiter = {
    description = "Periodically limit qBittorrent while Plex is active";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2min";
      # Thirty seconds is a compromise: quick enough to restore normal speeds
      # after playback stops, but not so frequent that it creates meaningful
      # qBittorrent API/config churn on the old server.
      OnUnitActiveSec = "30s";
      AccuracySec = "5s";
      Unit = "qbittorrent-plex-limiter.service";
    };
  };
}
