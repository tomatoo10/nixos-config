# qBittorrent WebUI-managed configuration

Native NixOS manages the service, ports, firewall, user/group, and `/srv/data`
directories. qBittorrent behavior is intentionally managed in the WebUI so
passwords, scheduler blobs, categories, and other runtime preferences are not
overwritten by rebuilds.

The live config file is:

```text
/var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf
```

Do not commit `WebUI\Password_PBKDF2` with its real value. The snapshot in this
folder is sanitized.

TRaSH settings still to verify in WebUI:

- Queueing enabled
- Maximum active downloads: `1`
- Maximum active uploads: `-1`
- Maximum active torrents: `-1`
- Download rate threshold: `5000 KiB/s`
- Upload rate threshold: `2 KiB/s`
- Torrent inactivity timer: `60s`
- Apply rate limit to µTP: enabled
- Apply rate limit to transport overhead: disabled
- Apply rate limit to peers on LAN: enabled
- Categories:
  - `movies` → `/srv/data/torrents/movies`
  - `tv` → `/srv/data/torrents/tv`
  - `anime` → `/srv/data/torrents/anime`
  - `music` → `/srv/data/torrents/music`
  - `books` → `/srv/data/torrents/books`
