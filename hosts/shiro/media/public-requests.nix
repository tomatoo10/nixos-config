# Overseerr/Cloudflare Tunnel public request portal scaffold is disabled by default; when enabled it must expose only Overseerr publicly and keep Plex/Arr/qBittorrent/Pi-hole private.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.shiro.media.publicRequests;
in {
  options.shiro.media.publicRequests.enable = lib.mkEnableOption "disabled Overseerr + Cloudflare Tunnel request portal scaffold";

  config = lib.mkIf cfg.enable {
    # Public request portal plan, intentionally disabled by default. When enabled,
    # Overseerr should be the only public app behind the Cloudflare Tunnel; Plex and
    # the Arr/qBittorrent admin surfaces must stay LAN/Tailscale-only.
    services.overseerr = {
      enable = true;
      port = 5055;
      openFirewall = false;
    };

    systemd.services.cloudflared-overseerr = {
      description = "Cloudflare Tunnel for Overseerr";
      after = ["network-online.target" "overseerr.service"];
      wants = ["network-online.target" "overseerr.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "10s";
        EnvironmentFile = "/var/lib/secrets/cloudflared-overseerr.env";
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN";
      };
    };
  };
}
