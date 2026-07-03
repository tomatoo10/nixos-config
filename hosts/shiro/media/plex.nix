# Plex is the direct-play-first media server for shiro; this file enables the native service and LAN/Tailscale firewall access while account claim, libraries, and metadata stay Plex-owned state.
{...}: {
  services.plex = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
}
