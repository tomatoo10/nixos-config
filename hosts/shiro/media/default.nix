# shiro media stack assembles the torrent, Arr, Plex, container, and Pi-hole
# modules together so the host configuration can import one section directory.
{
  imports = [
    ./common.nix
    ./qbittorrent
    ./qbittorrent/plex-limiter.nix
    ./arr.nix
    ./plex.nix
    ./containers.nix
    ./pihole.nix
    ./public-requests.nix
  ];
}
