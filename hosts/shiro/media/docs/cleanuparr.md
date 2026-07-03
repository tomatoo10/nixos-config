# Cleanuparr

## Nix ownership

- Module: `hosts/shiro/media/containers.nix`
- WebUI/API: `http://shiro:11011`
- Config/state: `/srv/cleanuparr/config`
- Downloads mount inside container: `/downloads`
- Host downloads path: `/srv/data/torrents`

The container is declarative. Cleanuparr rules, app API keys, users, sessions,
notifications, event history, and logs are configured through the WebUI and stored
in `/srv/cleanuparr/config`.

## App connections

Use shiro LAN URLs because Cleanuparr runs in a Podman container:

- Radarr: `http://192.168.18.7:7878`
- Sonarr: `http://192.168.18.7:8989`
- qBittorrent: `http://192.168.18.7:8080`

qBittorrent WebUI auth bypass must include `10.88.0.0/16` for the Podman bridge.

## Post-install WebUI checklist

After first setup or restore, configure/confirm these settings in the WebUI:

- qBittorrent client points at `http://192.168.18.7:8080/`.
- Download directory mapping: source `/srv/data/torrents`, target `/downloads`.
- Radarr instance points at `http://192.168.18.7:7878`.
- Sonarr instance points at `http://192.168.18.7:8989`.
- Queue cleaner enabled, currently every 10 minutes.
- `DownloadingMetadata` max strikes: `6`.
- Failed imports ignore private torrents and do not delete private data.
- Seeker search enabled, proactive search disabled.
- Public seeding rules exist for `movies`, `tv`, and `animes`.
- Unlinked detection watches `movies`, `tv`, and `animes` and moves matching
  orphaned payloads to `unlinked`.
- Public-only deletion exists for category `unlinked` with a `2h` max seed time
  and source-file deletion enabled.

Durable rule changes are made in the Cleanuparr WebUI, then documented here if
they become part of the expected setup. There is intentionally no database seed or
template for Cleanuparr rules.

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
- Trigger: public qBittorrent torrents that match the rule's ratio/time/seeder
  criteria.
- Action: remove from qBittorrent and delete source files once the qBittorrent
  rule matches.
- Exclude: private tracker torrents, torrents that still need to be kept for
  seeding, torrents with import/hardlink problems, and manually protected
  torrents.
- Current live public rules: ratio `4.0`, minimum seed time `24h`, maximum seed
  time `168h`, delete source files enabled, minimum seeders `5`.

These seeding rules are qBittorrent-level cleanup rules; they do not prove that
Radarr/Sonarr successfully imported a torrent. If imports are failing, pause or
disable cleanup before the retention window expires.

### Unlinked cleanup

- Scope: download folders `/downloads/movies`, `/downloads/tv`, `/downloads/animes`
- Target category: `unlinked`
- Purpose: identify torrent payloads that still exist on disk but no longer have
  hardlinks to active Radarr/Sonarr library files.
- This is post-import orphan cleanup, not broken-torrent cleanup. A torrent with
  missing files that cannot seed is a failed/stalled client state, not the normal
  meaning of `unlinked`.
- Common cause: Radarr/Sonarr upgrades or deletes a library file, leaving the old
  torrent's source files behind in qBittorrent.
- Action: move/mark to `unlinked` first; delete public unlinked source files
  after the configured review window.
- Current live review window: `2h` max seed time for the public `Unlinked cleanup`
  qBittorrent seeding rule.
- Exclude from detection: `/downloads/incomplete`, files from current in-progress
  downloads, cross-seed roots, and any manually staged files.
- Exclude from deletion: private tracker torrents and anything still expected to
  seed, even if it has been moved to `unlinked`.

Unlinked detection/category reassignment and unlinked deletion are separate
steps. Detection can move orphaned payloads to the `unlinked` category; the live
deletion rule is what restricts removal to public torrents. Do not assume every
torrent in `unlinked` is safe to delete manually without checking privacy and
seeding requirements.

### Malware/blocklist rule

- Enable public blocklists if available.
- Keep rule action conservative at first: remove obvious blocked releases and blacklist them in Arr.
- Review logs after enabling new blocklists to avoid false positives.

## Timing

Avoid aggressive cleanup on a low-memory home server:

- Run evaluations every 5-15 minutes for lightweight checks.
- Use multi-hour thresholds for stalled/slow removals.
- Use a short review window only for disposable public unlinked data. Current
  live `unlinked` cleanup is intentionally aggressive at `2h` because disk space
  is tight; keep private trackers excluded.

Current live timing to know about when debugging replacement delays:

- Queue cleaner evaluates every 10 minutes.
- `DownloadingMetadata` is removed after 6 strikes, so a metadata-only item can
  sit for about an hour before removal.
- Seeker replacement search is enabled, but runs on its own cadence after the
  queue item is removed; it is not immediate at the exact deletion timestamp.

## Blacklists

When Cleanuparr removes a bad release, blacklist it in Radarr/Sonarr if the release itself is bad. Do not blacklist when removal is caused by a local outage, permission issue, network downtime, or qBittorrent misconfiguration.

## Troubleshooting

- Container logs: `sudo podman logs cleanuparr`
- Systemd unit: `podman-cleanuparr.service`
- Config/logs: `/srv/cleanuparr/config`
- If qBittorrent returns 403, check auth bypass and that Cleanuparr uses the LAN URL.
- If imports break, make rules less aggressive and confirm Arr import status before deletion.
