# qBittorrent

## Nix ownership

- Module: `hosts/shiro/media/qbittorrent.nix`
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
- Add tracker list URL: `https://cf.trackerslist.com/best.txt`
- WebUI bind: `*`
- Auth bypass subnet whitelist enabled for: `127.0.0.1/32, ::1/128, 100.64.0.0/10, 192.168.18.0/24, 10.88.0.0/16`

The `10.88.0.0/16` entry is required because Cleanuparr reaches qBittorrent from the Podman bridge.

This auth bypass is acceptable only for the current LAN/Tailscale trust boundary. Do not expose qBittorrent publicly. If untrusted devices join the LAN/tailnet, narrow or remove the bypass and use normal WebUI authentication.

## Categories

Only these categories should exist:

| Category | Save path |
| --- | --- |
| `movies` | `movies` |
| `tv` | `tv` |
| `animes` | `animes` |
| `unlinked` | `unlinked` |

Effective paths become `/srv/data/torrents/<category>`.

Do not use `anime` as a qBittorrent category.

The `unlinked` category is required for Cleanuparr. It is not an active download
category for Radarr or Sonarr. Cleanuparr uses it as a holding area for torrent
payloads that still exist on disk but no longer have hardlinks to active
Radarr/Sonarr library files, such as old files left after an upgrade. Keep it
separate from `movies`, `tv`, and `animes`; do not point Arr download clients at
`unlinked`. The deletion rule for `unlinked` is public-only, but category
membership alone does not prove a torrent is disposable.

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
  after their configured retention windows.
- Cleanuparr moves post-import orphan payloads to `unlinked`, then the public-only
  unlinked cleanup rule removes public source files after the shorter review
  window.
- Private tracker torrents must remain excluded from aggressive cleanup.

## Restore notes

Restore `/var/lib/qBittorrent` from `hosts/shiro/media/config-backups/latest/var/lib/qBittorrent`, then rebuild so Nix reinstalls the desired categories and preferences.
