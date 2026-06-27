# Backups and restore

## Local ignored backup location

Backups live under:

- `hosts/shiro/media/config-backups/`

This path is ignored by Git because it contains live databases, API keys, cookies, and tokens. Do not force-add it.

The current backup convention is:

- `hosts/shiro/media/config-backups/latest/`

## Included state

- Radarr: `/var/lib/radarr`
- Sonarr: `/var/lib/sonarr`
- Prowlarr: `/var/lib/private/prowlarr`
- Bazarr: `/var/lib/bazarr`
- qBittorrent: `/var/lib/qBittorrent`
- Cleanuparr: `/srv/cleanuparr`
- Qui: `/var/lib/qui`
- Plex: `Preferences.xml` and `Plug-in Support/Databases`

Plex metadata cache/thumbnails and container image layers are intentionally not backed up in the lightweight config backup.

## Create or refresh backup

From the repo root on ryu, create a fresh backup with an SSH tar/untar flow. Stop services first if you need a perfectly consistent SQLite snapshot; otherwise this is a practical config snapshot.

Recommended consistent approach:

1. Stop the affected service on shiro.
2. Copy its directory into `hosts/shiro/media/config-backups/latest/`.
3. Start the service again.

For full-stack backups, prefer stopping the stack briefly before copying databases.

## Restore procedure

1. Stop the affected service.
2. Copy the matching backup path back to the same absolute path on shiro.
3. Restore ownership if needed.
4. Start the service.
5. Check logs.

Typical ownership:

- Radarr: `radarr:media`
- Sonarr: `sonarr:media`
- Bazarr: `bazarr:media`
- qBittorrent: `qbittorrent:media`
- Plex: `plex:media`
- Qui: `qui:qui`
- Cleanuparr: preserve backup ownership when possible. If repairing manually, make `/srv/cleanuparr/config` writable by the numeric UID/GID configured in `hosts/shiro/media/containers.nix` as `PUID`/`PGID`; do not assume the group name from the number without checking shiro.

## Git-owned alternatives

For qBittorrent categories and Recyclarr profiles, prefer restoring from Git-owned files and rebuilding shiro instead of copying old state blindly.
