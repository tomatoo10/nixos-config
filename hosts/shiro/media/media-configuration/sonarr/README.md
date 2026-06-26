# Sonarr WebUI-managed configuration

Sonarr stores application settings in its database under `/var/lib/sonarr` and
keeps its API key in `config.xml`. Do not commit Sonarr DBs or API keys.

Native NixOS starts Sonarr, and Recyclarr manages quality profiles/custom
formats. The following WebUI settings must exist after a rebuild/reinstall.

## General

- **App URL**: `http://localhost:8989`
- **Bind address**: `*` — declared in `hosts/shiro/media/arr.nix` so LAN clients can reach Sonarr.

## Root folders

- **TV Root Folder**: `/srv/data/media/tv`
- **Anime Root Folder**: `/srv/data/media/anime`

These are final library folders. Do not point Sonarr at `/srv/data/torrents`.

## Tags

- **Tag**: `tv` — used to route normal TV grabs.
- **Tag**: `anime` — used to route anime grabs.

If a series lacks the expected tag, it may have no eligible download client or
may route to the wrong qBittorrent category.

## Download clients

- **Download client name**: `qBittorrent - TV`
  - **Implementation**: qBittorrent
  - **Host**: `localhost`
  - **Port**: `8080`
  - **Category**: `tv`
  - **Tags**: `tv`
- **Download client name**: `qBittorrent - Animes`
  - **Implementation**: qBittorrent
  - **Host**: `localhost`
  - **Port**: `8080`
  - **Category**: `animes`
  - **Tags**: `anime`

Use the plural qBittorrent category `animes`; do not create/use a singular
`anime` torrent category.

Recyclarr sync manages:

- `Series - 1080p Remux`
- `Anime - 1080p Remux`

Prowlarr should be the only source of manually managed indexers synced into
Sonarr.
