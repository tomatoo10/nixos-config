# Qui is an optional qBittorrent alternate UI kept configured but disabled; enable only if its LAN/Tailscale auth-disabled exposure is worth the extra surface.
{...}: {
  # Optional qBittorrent alternate UI. Kept configured but disabled because the
  # stock qBittorrent WebUI is enough and Qui's auth-disabled mode broadens the
  # LAN/Tailscale attack surface.
  services.qui = {
    enable = false;
    openFirewall = false;
    secretFile = "/var/lib/secrets/qui-session.txt";
    settings = {
      host = "0.0.0.0";
      port = 7476;
      authDisabled = true;
      I_ACKNOWLEDGE_THIS_IS_A_BAD_IDEA = true;
      authDisabledAllowedCIDRs = ["192.168.18.0/24" "100.64.0.0/10"];
    };
  };
}
