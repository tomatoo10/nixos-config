# qBittorrent

## Nix ownership

- Module: `hosts/shiro/media/qbittorrent/default.nix`
- State: `/var/lib/qBittorrent`
- WebUI: `http://shiro:8080`
- Torrent port: `6881`
- Category source: `hosts/shiro/service-configs/qbittorrent/categories.json`
- Read-only desired category copy on shiro: `/etc/qbittorrent/categories.json`

Nix owns important WebUI preferences through `services.qbittorrent.serverConfig`. WebUI edits to those settings may be overwritten on restart/rebuild.

## Required WebUI settings

These should match the Nix config:

- Default save path: `/srv/data/torrents/`
- Incomplete path: `/srv/data/torrents/incomplete/`
- Torrent content layout: subfolder
- Queueing enabled; max active downloads: `1`
- Normal global speed limits: download `14100 KiB/s`, upload `13350 KiB/s`
- Plex-active speed limits: download `1 MiB/s`, upload `100 KiB/s`
- Add tracker list URL: `https://cf.trackerslist.com/best.txt`
- WebUI bind: `*`
- Auth bypass subnet whitelist enabled for: `127.0.0.1/32, ::1/128, 100.64.0.0/10, 192.168.18.0/24, 10.88.0.0/16`

The `10.88.0.0/16` entry is required because Cleanuparr reaches qBittorrent from the Podman bridge.

This auth bypass is acceptable only for the current LAN/Tailscale trust boundary. Do not expose qBittorrent publicly. If untrusted devices join the LAN/tailnet, narrow or remove the bypass and use normal WebUI authentication.

## Plex-active speed limiter

Plex direct play on `shiro` is sensitive to disk contention from torrent IO. Nix
therefore installs a systemd timer that checks Plex sessions and applies
conservative qBittorrent limits over the local Web API only while Plex is
actively playing or buffering:

- `qbittorrent-plex-limiter.timer`: runs every 30 seconds after boot.
- `qbittorrent-plex-limiter.service`: reads Plex's local token from
  `/var/lib/plex/Plex Media Server/Preferences.xml`, checks
  `http://localhost:32400/status/sessions`, and applies either Plex-active
  limits or normal limits.
- Plex-active limits: `1 MiB/s` download and `100 KiB/s` upload.
- Normal limits: `14100 KiB/s` download and `13350 KiB/s` upload.

This intentionally uses a local timer instead of qBittorrent's built-in bandwidth
scheduler because active Plex playback is a better signal than fixed clock
windows and avoids throttling torrents when nobody is watching.

## Categories

Only these categories should exist:

| Category | Save path |
| --- | --- |
| `movies` | `movies` |
| `tv` | `tv` |
| `animes` | `animes` |
| `books` | `books` |
| `unlinked` | `unlinked` |
| `dead-torrents` | `dead-torrents` |

Effective paths become `/srv/data/torrents/<category>`.

Do not use `anime` as a qBittorrent category. The `books` category is scaffolded for possible future use and must not be reused for movies, TV, or anime.

The `unlinked` category is required for Cleanuparr. It is not an active download
category for Radarr or Sonarr. Cleanuparr uses it as a holding area for torrent
payloads that still exist on disk but no longer have hardlinks to active
Radarr/Sonarr library files, such as old files left after an upgrade. Keep it
separate from `movies`, `tv`, `animes`, and `books`; do not point Arr download clients at
`unlinked`. The deletion rule for `unlinked` is public-only, but category
membership alone does not prove a torrent is disposable.

The `dead-torrents` category is also reserved for Cleanuparr quarantine / dead
torrent handling. It should behave like a cleanup holding area, not an Arr
download-client route, and it must not replace `animes`.

The category list is Git-owned and reinstalled from
`hosts/shiro/service-configs/qbittorrent/categories.json` when qBittorrent
starts. Treat WebUI category edits as temporary unless exported back to Git.

## Updating category state

1. Prefer editing `hosts/shiro/service-configs/qbittorrent/categories.json` in Git.
2. Rebuild/switch shiro.
3. Restart qBittorrent if needed.
4. Confirm WebUI categories match the JSON.

If a WebUI category edit is unavoidable, export `/var/lib/qBittorrent/qBittorrent/config/categories.json` back into the repo immediately.

## Cleanup and seeding policy

qBittorrent currently does not set global ratio/time limits. Cleanup policy is
owned by Radarr/Sonarr completed-download handling plus Cleanuparr rules:

- Radarr/Sonarr remove completed downloads after imports when the client state
  allows it.
- Cleanuparr removes public seeded leftovers from `movies`, `tv`, and `animes`
  after their configured retention windows. Add `books` only after Cleanuparr has an explicit book cleanup rule.
- Cleanuparr moves post-import orphan payloads to `unlinked`, then the public-only
  unlinked cleanup rule removes public source files after the shorter review
  window.
- Private tracker torrents must remain excluded from aggressive cleanup.

## Restore notes

Restore `/var/lib/qBittorrent` from `hosts/shiro/media/config-backups/latest/var/lib/qBittorrent`, then rebuild so Nix reinstalls the desired categories and preferences.
