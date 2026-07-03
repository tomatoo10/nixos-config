# shiro media common creates the shared media group so Radarr/Sonarr/Bazarr/qBittorrent/Plex-sidecar workflows can share writable library and torrent paths.
{
  config,
  ...
}: {
  # Shared media group keeps apps and cleanup containers aligned on ownership.
  users.groups.media = {};
  users.users."${config.var.username}".extraGroups = ["media"];
}
