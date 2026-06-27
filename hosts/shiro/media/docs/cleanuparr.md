# Cleanuparr

## Nix ownership

- Module: `hosts/shiro/media/containers.nix`
- WebUI/API: `http://shiro:11011`
- Config/state: `/srv/cleanuparr/config`
- Downloads mount inside container: `/downloads`
- Host downloads path: `/srv/data/torrents`

Cleanuparr rules, blacklists, app API keys, and UI settings are stateful. The container is declarative; the app config is not.

## App connections

Use shiro LAN URLs because Cleanuparr runs in a Podman container:

- Radarr: `http://192.168.18.7:7878`
- Sonarr: `http://192.168.18.7:8989`
- qBittorrent: `http://192.168.18.7:8080`

qBittorrent WebUI auth bypass must include `10.88.0.0/16` for the Podman bridge.

## Categories

Rules must use exactly these qBittorrent categories:

- `movies`
- `tv`
- `animes`
- `unlinked`

Never use singular `anime`.

## Recommended rules

Create separate rules so actions are explainable and safe.

### Stalled downloads

- Scope: categories `movies`, `tv`, `animes`
- Trigger: stalled/no-progress torrents after a reasonable grace period, for example 2-4 hours.
- Action: remove from qBittorrent and optionally blacklist in the matching Arr app.
- Exclude: paused torrents, manually tagged keep items, very large torrents still actively downloading slowly.

### Slow downloads

- Scope: categories `movies`, `tv`, `animes`
- Trigger: speed below a threshold for a sustained period, for example below 100-300 KiB/s for 6-12 hours.
- Action: remove and blacklist if it repeatedly wastes slots.
- Exclude: newly added torrents and torrents close to completion.

### Seeding cleanup

- Scope: categories `movies`, `tv`, `animes`
- Trigger: imported/completed torrents that have met your retention target.
- Action: remove from qBittorrent only after Arr import completed.
- Exclude: torrents not imported yet, torrents with hardlink/import issues, manually protected torrents.

### Unlinked cleanup

- Scope: download folders `/downloads/movies`, `/downloads/tv`, `/downloads/animes`
- Target category: `unlinked`
- Purpose: identify files no longer linked to Radarr/Sonarr items.
- Action: move/mark to `unlinked` first; delete only after a review window.
- Exclude: `/downloads/incomplete`, active category folders for current downloads, and any manually staged files.

### Malware/blocklist rule

- Enable public blocklists if available.
- Keep rule action conservative at first: remove obvious blocked releases and blacklist them in Arr.
- Review logs after enabling new blocklists to avoid false positives.

## Timing

Avoid aggressive cleanup on a low-memory home server:

- Run evaluations every 5-15 minutes for lightweight checks.
- Use multi-hour thresholds for stalled/slow removals.
- Use at least a day-scale review window before deleting unlinked data.

## Blacklists

When Cleanuparr removes a bad release, blacklist it in Radarr/Sonarr if the release itself is bad. Do not blacklist when removal is caused by a local outage, permission issue, network downtime, or qBittorrent misconfiguration.

## Troubleshooting

- Container logs: `sudo podman logs cleanuparr`
- Config/logs: `/srv/cleanuparr/config`
- If qBittorrent returns 403, check auth bypass and that Cleanuparr uses the LAN URL.
- If imports break, make rules less aggressive and confirm Arr import status before deletion.
