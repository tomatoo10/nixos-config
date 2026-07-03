# shiro media stack docs

These docs describe the stateful WebUI/API configuration that cannot be fully represented in NixOS modules yet. Nix owns service enablement, ports, filesystem layout, qBittorrent major preferences/categories, and Pi-hole local DNS records. The apps still own their own databases, credentials, cookies, indexers, libraries, and interactive settings.

Read `AGENTS.md` first for the global contract, then the matching service guide before changing WebUI state.

## Services

- `qbittorrent.md` — download client paths, categories, auth bypass, restore/export.
- `radarr.md` — movie root folder, qBittorrent client, Prowlarr sync, profiles.
- `sonarr.md` — TV/anime roots, tags, qBittorrent routing, profiles.
- `bazarr.md` — subtitle profiles, automatic searches, Plex-friendly SRT sidecars.
- `prowlarr-byparr.md` — indexers, app sync, Byparr/FlareSolverr-compatible proxy.
- `recyclarr.md` — removed-service note and re-add guidance.
- `profilarr.md` — main profile-management experiment.
- `plex.md` — libraries, access URLs, LAN/Tailscale, subtitles/transcoding.
- `cleanuparr.md` — cleanup rules, categories, blacklists, timing, exclusions.
- `qui.md` — removed-service note for the optional qBittorrent UI.
- `overseerr-cloudflared.md` — disabled public request portal/tunnel scaffold.
- `pihole.md` — LAN DNS/ad-blocking service, router setup, and local DNS records.
- `backups.md` — local ignored config backup/restore procedure.
- `audit.md` — prioritized follow-ups and cleanup candidates for the shiro stack.

## Canonical paths

- Movies library: `/srv/data/media/movies`
- TV library: `/srv/data/media/tv`
- Anime library: `/srv/data/media/anime`
- Books library: `/srv/data/media/books`
- Profilarr config: `/srv/profilarr/config`
- Pi-hole state: `/var/lib/pihole`
- Pi-hole config: `/etc/pihole`
- Torrents root: `/srv/data/torrents`
- Incomplete torrents: `/srv/data/torrents/incomplete`
- qBittorrent categories: `movies`, `tv`, `animes`, `books`, `unlinked`

Do not create or document a singular torrent category named `anime`.
