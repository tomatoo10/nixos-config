# Radarr WebUI-managed configuration

Radarr stores application settings in its database under `/var/lib/radarr` and
keeps its API key in `config.xml`. Do not commit Radarr DBs or API keys.

Native NixOS starts Radarr, and Recyclarr manages quality profiles/custom
formats. The following WebUI settings must exist after a rebuild/reinstall.

## General

- **App URL**: `http://localhost:7878`
- **Bind address**: `*` — declared in `hosts/shiro/media/arr.nix` so LAN clients can reach Radarr.

## Media management

- **Root Folder**: `/srv/data/media/movies`
  - Use this as the final movie library.
  - Do not use `/srv/data`, `/srv/data/torrents`, or a qBittorrent category folder as a Radarr root.

## Download client

- **Download client name**: `qBittorrent`
- **Implementation**: qBittorrent
- **Host**: `localhost`
- **Port**: `8080`
- **Category**: `movies`
- **Tags**: empty

The category must stay `movies` so completed downloads land in
`/srv/data/torrents/movies` and import into `/srv/data/media/movies`.

Recyclarr sync manages the profile/custom-format side:

- `Movies - 1080p Remux`
- `Movies - 4K Test`

Prowlarr should be the only source of manually managed indexers synced into
Radarr.
