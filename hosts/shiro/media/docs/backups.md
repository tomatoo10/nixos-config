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
- Pi-hole: `/etc/pihole`, `/var/lib/pihole`
- Plex: `Preferences.xml` and `Plug-in Support/Databases`

Plex metadata cache/thumbnails and container image layers are intentionally not backed up in the lightweight config backup.

## Create or refresh backup

From the repo root on ryu, create a fresh backup with an SSH tar/untar flow.

Stop services first when copying SQLite databases or when you need a clean restore
point. Hot copies are acceptable only for quick, best-effort snapshots before a
small change.

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
5. Open the WebUI and check that the app sees its database/config.
6. Check logs.

Recommended restore order for a full media-stack restore:

1. qBittorrent
2. Radarr/Sonarr/Prowlarr/Bazarr
3. Plex
4. Profilarr/Cleanuparr/Qui
5. Pi-hole

Pi-hole restore check:

```bash
systemctl status pihole-ftl --no-pager
dig @192.168.18.7 example.com
```

Media app restore check:

- WebUI opens.
- API key still works where another app depends on it.
- Root folders exist and pass health checks.
- qBittorrent categories still match `qbittorrent.md`.

Typical ownership:

- Radarr: `radarr:media`
- Sonarr: `sonarr:media`
- Bazarr: `bazarr:media`
- qBittorrent: `qbittorrent:media`
- Plex: `plex:media`
- Qui: `qui:qui`
- Cleanuparr: preserve backup ownership when possible. If repairing manually, make `/srv/cleanuparr/config` writable by the numeric UID/GID configured in `hosts/shiro/media/containers.nix` as `PUID`/`PGID`; do not assume the group name from the number without checking shiro.
- Pi-hole: preserve ownership from the live system; keep passwords and query DBs out of Git. Local DNS records are Nix-owned unless moved back to WebUI state later.

## Git-owned alternatives

For qBittorrent categories and Recyclarr profiles, prefer restoring from Git-owned files and rebuilding shiro instead of copying old state blindly.
