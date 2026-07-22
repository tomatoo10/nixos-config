# shiro media stack docs

These docs describe the stateful WebUI/API configuration that cannot be fully represented in NixOS modules yet. Nix owns service enablement, ports, filesystem layout, qBittorrent major preferences/categories, and Pi-hole local DNS records. The apps still own their own databases, credentials, cookies, indexers, libraries, blocklists, and interactive settings.

Read `AGENTS.md` first for the global contract, then the matching service guide before changing WebUI state.

## Services

- `qbittorrent.md` — download client paths, categories, auth bypass, restore/export.
- `radarr.md` — movie root folder, qBittorrent client, Prowlarr sync, profiles.
- `sonarr.md` — TV/anime roots, tags, qBittorrent routing, profiles.
- `bazarr.md` — subtitle profiles, automatic searches, Plex-friendly SRT sidecars.
- `prowlarr-byparr.md` — indexers, app sync, Byparr/FlareSolverr-compatible proxy.
- `chaptarr.md` — ebook manager caveats, paths, and client routing.
- `kavita.md` — ebook library service notes.
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
- Chaptarr config: `/srv/chaptarr/config`
- Kavita config: `/srv/kavita/config`
- Pi-hole state: `/var/lib/pihole`
- Pi-hole config: `/etc/pihole`
- Torrents root: `/srv/data/torrents`
- Incomplete torrents: `/srv/data/torrents/incomplete`
- qBittorrent categories: `movies`, `tv`, `animes`, `books`, `unlinked`

Do not create or document a singular torrent category named `anime`.

## Stateful / manual configuration

Keep these out of Git unless a service-specific guide explicitly says otherwise:

| Area | Owner | Notes |
| --- | --- | --- |
| Radarr/Sonarr/Prowlarr/Bazarr profiles, API keys, indexers, history | WebUI/API state | Document intended settings, but do not commit live databases or `config.xml` secrets. |
| Pi-hole gravity blocklists, query DB, WebUI password | Pi-hole state | Nix owns upstream DNS, local DNS records, and limits. Do not use `services.pihole-ftl.lists` for default blocklists because that setup step is not idempotent on existing Pi-hole databases. |
| Plex account, claim, libraries, metadata, watch state | Plex state | Keep tokens and databases out of Git. Nix only enables the service and networking assumptions. |
| Cleanuparr users/API keys/rules/event history | Cleanuparr state | Back up locally under the ignored backup procedure; do not commit DBs. |
| Kavita/Chaptarr initial accounts/libraries and image pulls | Manual/WebUI state | Containers are declared but `autoStart = false`; pull and start manually after verifying image availability on shiro. |
| Router DHCP/DNS/IPv6 settings | Router WebUI state | For Pi-hole, hand out shiro directly as DNS: IPv4 `192.168.18.7`, IPv6 `fd7a:c324:7131::7`. |

## Quality profile choices

shiro is a direct-play-first Plex server on old laptop hardware and the current
LAN path has shown only about 6-8 Mbps of stable shiro-to-client throughput in
some tests. Prefer profiles that keep releases around moderate 1080p bitrates
instead of chasing remux, 2160p, or HDR-heavy files.

Recommended defaults:

| Library type | Default profile | Higher-quality option | Avoid as default |
| --- | --- | --- | --- |
| Anime | `Anime - 1080p Efficient (shiro)` | `Anime - 1080p Remux Legacy` only when quality matters more and playback is tested | high-bitrate HDTV/x264 fallbacks, remux-first anime for routine use |
| TV series | `1080p Efficient` | `1080p Balanced` for favorites | `1080p Quality`, `1080p Remux`, 2160p profiles |
| Movies | `1080p Efficient` | `1080p Balanced` for favorites | `1080p Remux`, 2160p profiles, `1080p Quality HDR` as a blanket default |

`1080p Quality HDR` may still grab x265/HEVC releases, but it optimizes for HDR
quality rather than shiro playback safety. Use it only for titles where HDR is
intentional and the target Plex client can direct-play that HDR/DV file without
tone mapping or buffering.

For problematic playback, prefer replacing the release with a smaller efficient
1080p WEB-DL/Bluray release before changing server-side Plex settings. x265/HEVC
is useful as a tie-breaker, but not a guarantee: source, bitrate, subtitles, HDR,
and the playback client still matter.
