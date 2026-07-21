# qBittorrent is the shared torrent client; this file owns service ports,
# media-group umask, and Git-owned categories while torrent state and
# credentials stay under /var/lib/qBittorrent.
{pkgs, ...}: let
  # Nix owns qBittorrent categories for reproducible rebuilds. Edit this JSON in
  # Git instead of changing categories in the WebUI.
  desiredCategories = ../service-configs/qbittorrent/categories.json;
in {
  services.qbittorrent = {
    enable = true;
    group = "media";
    webuiPort = 8080;
    torrentingPort = 6881;
    # Firewall policy is centralized in hosts/shiro/networking.nix: the peer
    # port remains globally reachable, while the WebUI is source-restricted to
    # private LAN/Tailscale/Podman clients.
    openFirewall = false;
    # qBittorrent.conf is generated from the exported live baseline in
    # hosts/shiro/service-configs/qbittorrent/qBittorrent.conf. Once this is
    # active, Nix owns these WebUI preferences; WebUI edits to them can be
    # overwritten on restart/rebuild.
    serverConfig = import ./qbittorrent/preferences.nix;
  };

  systemd.services.qbittorrent = {
    # qBittorrent reads categories.json on startup and may rewrite it on
    # shutdown. Install the Git/Nix-owned copy before each start so categories
    # are reproducible after rebuilds and reinstalls.
    # Ensure qBittorrent creates files with group write permissions (0664
    # instead of 0644). This allows Radarr/Sonarr (also members of the
    # 'media' group) to hardlink downloaded files instead of falling back
    # to copying them, which is required for efficient imports and for
    # tools like Cleanuparr to correctly detect linked torrents.
    serviceConfig.UMask = "0002";
    preStart = ''
      ${pkgs.coreutils}/bin/install -Dm600 -o qbittorrent -g media \
        ${desiredCategories} \
        /var/lib/qBittorrent/qBittorrent/config/categories.json
    '';
  };

  # Handy read-only copy of desired category state for operators.
  environment.etc."qbittorrent/categories.json".source = desiredCategories;
}
