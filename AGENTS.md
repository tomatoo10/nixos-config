# NixOS Configuration Agent Guide

This repository manages the user's NixOS machines and the shiro home-server media stack. The active hosts are `ryu`, `sora`, and `shiro`; older migration notes are historical only and must not be treated as source of truth.

## Non-negotiable engineering policy

- Do not introduce hacks, monkey patches, duct tape, or partial workarounds.
- Prefer robust, clear, maintainable designs over short-term convenience.
- Backwards compatibility is not important when preserving it would keep a bad design. Fix the design instead.
- Keep secrets out of Git unless the repository explicitly documents an accepted exception.
- If the requested result cannot be done cleanly, stop and explain the blocker.
- If a fix has uncertain side effects, looks workaround-like, or has multiple
  plausible clean approaches, present the options and ask before applying it.
- After every change, report anything fragile, uncertain, or workaround-like.

## Repository layout

- `flake.nix` — host inventory, inputs, and NixOS system construction.
- `hosts/` — host-specific configuration: `ryu`, `sora`, and `shiro`.
- `modules/` — reusable NixOS modules grouped into `core`, `boot`, `desktop`, `hardware`, `virtualisation`, and `gaming`.
- `home/` — Home Manager program and desktop configuration.
- `themes/` — Stylix theme modules.
- `hosts/shiro/media/docs/` — operator setup and restore docs for shiro media apps, including Pi-hole.
- `hosts/shiro/service-configs/` — Git-owned exported service config fragments.

## Host policy

- `ryu`: main desktop. Firewall is disabled for HTB. Tailscale is enabled but must not accept DNS; home DNS should come from DHCP/Pi-hole: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`.
- `sora`: laptop. OpenSSH is intentionally disabled. Tailscale is enabled but must not accept DNS; home DNS should come from DHCP/Pi-hole and away-from-home DNS should come from the active network unless a deliberate conditional/Tailscale DNS design is added later: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`.
- `shiro`: home server at LAN IP `192.168.18.7`; use `ssh shiro.lan` for live checks. Tailscale is enabled but should not accept DNS: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`. Docker is not enabled. Podman-backed `virtualisation.oci-containers` is used only for auxiliary services. `zramSwap` is intentionally enabled for low-memory resilience. Pi-hole runs natively on `192.168.18.7:53` and `192.168.18.7:8081`.

## shiro media stack contract

The active stack is native Radarr, Sonarr, Bazarr, Prowlarr, qBittorrent, Plex, and Pi-hole, plus Podman containers for Cleanuparr, Byparr, and Profilarr. Qui and Recyclarr were removed because Profilarr and the stock qBittorrent WebUI are the active paths. Readarr is not enabled, but books paths/categories are scaffolded for possible future use. Overseerr and Cloudflare Tunnel are scaffolded but disabled. Keep all apps consistent when changing paths, tags, categories, cleanup rules, DNS, or download-client routing.

### Playback constraints and client targets

- `shiro` runs on an old compact notebook and must be treated as a **direct-play-first** Plex server.
- Do not assume `shiro` can handle video transcoding, audio transcoding, or subtitle burn-in at acceptable performance.
- Avoid media-selection strategies that depend on server-side transcoding for compatibility.
- Prefer formats that direct play reliably on the main clients: `ryu`, `sora`, the ThinkPad T14 Gen 1 AMD, and iPhone 13.
- Prefer external `.srt` sidecar subtitles. Embedded bitmap subtitles such as PGS/VobSub are high risk because they often force Plex to burn subtitles into the video.
- When tuning Radarr/Sonarr/Bazarr/Profilarr for `shiro`, optimize first for smooth playback and subtitle compatibility, then for absolute quality.

### Filesystem layout

- Shared data root: `/srv/data`
- Final media libraries: movies `/srv/data/media/movies`, TV `/srv/data/media/tv`, anime `/srv/data/media/anime`, books `/srv/data/media/books`.
- qBittorrent download root: `/srv/data/torrents`.
- qBittorrent incomplete path: `/srv/data/torrents/incomplete`.
- Active qBittorrent category paths: `movies` -> `/srv/data/torrents/movies`, `tv` -> `/srv/data/torrents/tv`, `animes` -> `/srv/data/torrents/animes`, `books` -> `/srv/data/torrents/books`, `unlinked` -> `/srv/data/torrents/unlinked`.

Do not use the singular torrent category/path `anime`. Sonarr's logical anime tag is `anime`, but the qBittorrent category is `animes`.

Radarr and Sonarr root folders must point at final library folders, not torrent folders and not `/srv/data` directly.

### Network and service URLs

- Same-machine app links should use localhost: qBittorrent `localhost:8080`, Radarr `localhost:7878`, Sonarr `localhost:8989`, Prowlarr `localhost:9696`, Byparr `localhost:8191`.
- Same-LAN clients should use shiro LAN IP `192.168.18.7`.
- Tailscale clients can still reach shiro by Tailscale IP. MagicDNS names such as
  `shiro` are not guaranteed through the system resolver on ryu/sora because they
  do not accept Tailscale DNS.
- Container-to-host callbacks should use `192.168.18.7` unless the container is explicitly configured for host networking.
- Pi-hole WebUI: `http://192.168.18.7:8081/admin`.

### qBittorrent

- Module: `hosts/shiro/media/qbittorrent.nix`; WebUI: `http://shiro:8080`; state: `/var/lib/qBittorrent`.
- Categories are Git-owned in `hosts/shiro/service-configs/qbittorrent/categories.json`.
- Nix owns important preferences via `services.qbittorrent.serverConfig`.
- The committed qBittorrent password hash is an accepted LAN/Tailscale-only exception.

### Radarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:7878`.
- Root folder: `/srv/data/media/movies`.
- qBittorrent download client: `localhost:8080`, category `movies`, no Radarr download-client tags.
- Profilarr is the active profile-management path for Radarr.

### Sonarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:8989`.
- Root folders: `/srv/data/media/tv` and `/srv/data/media/anime`.
- Tags: `tv` for normal series, `anime` for anime.
- Download clients: `qBittorrent - TV` category `tv` restricted to tag `tv`; `qBittorrent - Animes` category `animes` restricted to tag `anime`.
- Profilarr is the active profile-management path for normal series.

### Bazarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:6767`.
- Writes sidecar subtitles into Radarr/Sonarr library folders; prefer SRT for
  Plex compatibility, but ASS/SSA sidecars are acceptable for anime when useful.
- Keep embedded subtitles from satisfying wanted sidecar searches; parse
  embedded audio tracks for profile decisions, but do not rely on embedded
  subtitle tracks as the only subtitle source.
- Keep Bazarr's risky built-in auto-sync disabled for dual-audio anime unless a
  tested reference-stream policy is in place; use the Nix-owned subtitle guard
  to quarantine impossible sidecar timing.
- Radarr, Sonarr, and Bazarr use `UMask = "0002"` so the shared `media` group can write sidecars and imports consistently.
- Prefer SRT sidecars for Plex Web/mobile compatibility.

### Prowlarr and Byparr

- Prowlarr module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:9696`.
- Byparr module: `hosts/shiro/media/containers.nix`; local URL: `http://localhost:8191`.
- Prowlarr is the source of truth for indexers. Do not duplicate Prowlarr-managed indexers in Radarr/Sonarr.
- App sync level should be `fullSync` for both Radarr and Sonarr.
- Configure Byparr in Prowlarr as a FlareSolverr-compatible indexer proxy tagged `byparr`, and apply that tag only to indexers that need Cloudflare/DDoS-GUARD solving.

### Profilarr

- Profilarr is the main profile-management experiment for Radarr/Sonarr at `http://shiro:6868` with config in `/srv/profilarr/config`.
- Recyclarr was removed. Re-add it only if Profilarr is no longer managing the same profiles/custom formats.

### Plex

- Module: `hosts/shiro/media/plex.nix`; WebUI: `http://shiro:32400/web`.
- Custom access URLs should include LAN and Tailscale: `http://192.168.18.7:32400`, `http://100.110.91.84:32400`.
- Allowed networks should include LAN, Podman, and Tailscale: `192.168.18.0/24,10.88.0.0/16,100.64.0.0/10`.
- Prefer SRT sidecar subtitles. Embedded VobSub/PGS bitmap subtitles often force burn-in/video transcode in Plex Web.

### Cleanuparr

- Module: `hosts/shiro/media/containers.nix`; WebUI/API: `http://shiro:11011`.
- Config: `/srv/cleanuparr/config`; downloads mount: `/srv/data/torrents:/downloads`.
- Arr URLs should use shiro LAN: Radarr `http://192.168.18.7:7878`, Sonarr `http://192.168.18.7:8989`.
- qBittorrent WebUI auth bypass must include `10.88.0.0/16` because Cleanuparr reaches qBittorrent from the Podman bridge.
- Rules must use categories `movies`, `tv`, `animes`, and `unlinked`; never singular `anime`.

### Removed: Qui

- Qui was removed because the stock qBittorrent WebUI is enough and Qui's auth-disabled LAN/Tailscale mode broadens exposure. Re-add only if a separate qBittorrent UI is actively needed.

### Overseerr / Cloudflare Tunnel

- Module: `hosts/shiro/media/public-requests.nix`; disabled by default through `shiro.media.publicRequests.enable = false`.
- Planned public service: expose only Overseerr (`localhost:5055`) through Cloudflare Tunnel; keep Plex, Arr apps, qBittorrent, and Pi-hole private to LAN/Tailscale.
- Cloudflare Access/WAF country filtering belongs in Cloudflare, not in this repo, unless later managed declaratively.

## State vs Git

Git-owned/declarative: NixOS modules, qBittorrent major preferences, qBittorrent categories, Pi-hole upstreams/local DNS records, and operator docs.

Stateful/WebUI-owned: Radarr, Sonarr, Prowlarr, Bazarr, Plex, Cleanuparr, and Pi-hole databases/configs; Prowlarr indexers; Plex claim/account/library state; Profilarr profile state; Cleanuparr users/API keys/rules/notifications/event history; Pi-hole password/query DB.

Ignored local backups: `hosts/shiro/media/config-backups/` stores live databases, API keys, tokens, and cookies and is intentionally ignored.

When investigating problems with the home-server applications, inspect live state on `shiro` with `ssh shiro.lan` instead of relying only on local backup snapshots. Use the least-invasive live checks available: service logs/status, application APIs, state databases, and container logs. Keep secrets out of responses and Git.

## Service documentation

Before changing WebUI-managed service state, read the matching guide in `hosts/shiro/media/docs/`: `qbittorrent.md`, `radarr.md`, `sonarr.md`, `bazarr.md`, `prowlarr-byparr.md`, `profilarr.md`, `plex.md`, `cleanuparr.md`, `overseerr-cloudflared.md`, `pihole.md`, and `backups.md`. `recyclarr.md` and `qui.md` are removed-service notes, not active service guides.

## Validation checklist

After repository changes, run the smallest relevant checks: `nix eval .#nixosConfigurations.shiro.config.system.stateVersion`, the matching host evals for ryu/sora when touched, and `git diff --check`.

After shiro media changes, also check live services when appropriate with `systemctl status radarr sonarr prowlarr bazarr qbittorrent plex pihole-FTL podman-cleanuparr --no-pager` and `sudo podman ps`.

After Pi-hole/DNS changes, validate Prowlarr indexer tests, qBittorrent tracker resolution, Radarr/Sonarr search/grab flow, Byparr proxying, and a basic Plex playback/UI sanity check.

## Commit messages

When asked to commit, use a descriptive title and include a concise explanation of what changed, why it changed, and any migration/runtime impact.
