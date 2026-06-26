# Cleanuparr WebUI-managed configuration

Cleanuparr stores settings, users, API keys, JWT keys, and event state in SQLite
databases under `/srv/cleanuparr/config`. Do not commit those databases.

Nix declares the container and mounts. The WebUI rules below must be recreated
after a fresh install if the database is not restored.

## Container/runtime

- **Container image**: `ghcr.io/cleanuparr/cleanuparr:latest`
- **WebUI/app URL**: `http://192.168.18.7:11011`
- **Config volume**: `/srv/cleanuparr/config:/config`
- **Downloads volume**: `/srv/data/torrents:/downloads`
- **PUID/PGID**: `1000:1000`
- **UMASK**: `002`

## Arr instances

- **Radarr URL**: `http://192.168.18.7:7878`
- **Sonarr URL**: `http://192.168.18.7:8989`

Use shiro's LAN IP here because Cleanuparr is inside a container; `localhost`
would refer to the container itself.

## qBittorrent download client

- **Type**: qBittorrent
- **URL/host**: `http://192.168.18.7:8080/`
- **Download directory source**: `/srv/data/torrents`
- **Download directory target**: `/downloads`
- **External URL**: `http://shiro:8080` if needed for display/links.

qBittorrent auth bypass must include Podman's bridge subnet `10.88.0.0/16`,
because Cleanuparr reaches qBittorrent from its container IP, not from
`192.168.18.7` or `127.0.0.1`.

Rules to keep aligned:

- **Categories**: `movies`, `tv`, `animes`, `unlinked`
- **Unlinked scan paths**: `/downloads/movies`, `/downloads/tv`, `/downloads/animes`
- **Unlinked target category**: `unlinked`
- **Seeding rules**:
  - Movies: category `movies`
  - TV: category `tv`
  - Animes: category `animes`
  - Unlinked cleanup: category `unlinked`

Never use the singular qBittorrent category `anime`.
