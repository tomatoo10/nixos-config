# Plex is the direct-play-first media server for shiro; this file enables the native service while account claim, libraries, metadata, and centralized LAN/Tailscale firewall exposure stay outside Plex-owned state.
{...}: {
  services.plex = {
    enable = true;
    group = "media";
    openFirewall = false;
  };
}
