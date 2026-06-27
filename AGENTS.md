# NixOS Configuration Agent Guide

This repository manages the user's NixOS machines and the shiro home-server media stack. The active hosts are `ryu`, `sora`, and `shiro`; older migration notes are historical only and must not be treated as source of truth.

## Non-negotiable engineering policy

- Do not introduce hacks, monkey patches, duct tape, or partial workarounds.
- Prefer robust, clear, maintainable designs over short-term convenience.
- Backwards compatibility is not important when preserving it would keep a bad design. Fix the design instead.
- Keep secrets out of Git unless the repository explicitly documents an accepted exception.
- If the requested result cannot be done cleanly, stop and explain the blocker.
- After every change, report anything fragile, uncertain, or workaround-like.

## Repository layout

- `flake.nix` — host inventory, inputs, and NixOS system construction.
- `hosts/` — host-specific configuration: `ryu`, `sora`, and `shiro`.
- `modules/` — reusable NixOS modules grouped into `core`, `boot`, `desktop`, `hardware`, `virtualisation`, and `gaming`.
- `home/` — Home Manager program and desktop configuration.
- `themes/` — Stylix theme modules.
- `hosts/shiro/media/docs/` — operator setup and restore docs for shiro media apps.
- `hosts/shiro/service-configs/` — Git-owned exported service config fragments.

## Host policy

- `ryu`: main desktop. Firewall is disabled for HTB. Tailscale must accept DNS so `shiro` works: `extraSetFlags = ["--ssh=true" "--accept-dns=true"]`.
- `sora`: laptop. OpenSSH is intentionally disabled. Tailscale must accept DNS so `shiro` works: `extraSetFlags = ["--ssh=true" "--accept-dns=true"]`.
- `shiro`: home server at LAN IP `192.168.18.7`. Tailscale is enabled but should not accept DNS: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`. Docker is not enabled. Podman-backed `virtualisation.oci-containers` is used only for auxiliary services. `zramSwap` is intentionally enabled for low-memory resilience.

## shiro media stack contract

The active stack is native Radarr, Sonarr, Bazarr, Prowlarr, qBittorrent, Plex, Recyclarr, and Qui, plus Podman containers for Cleanuparr and Byparr. Keep all apps consistent when changing paths, tags, categories, cleanup rules, or download-client routing.

### Filesystem layout

- Shared data root: `/srv/data`
- Final media libraries: movies `/srv/data/media/movies`, TV `/srv/data/media/tv`, anime `/srv/data/media/anime`.
- qBittorrent download root: `/srv/data/torrents`.
- qBittorrent incomplete path: `/srv/data/torrents/incomplete`.
- Active qBittorrent category paths: `movies` -> `/srv/data/torrents/movies`, `tv` -> `/srv/data/torrents/tv`, `animes` -> `/srv/data/torrents/animes`, `unlinked` -> `/srv/data/torrents/unlinked`.

Do not use the singular torrent category/path `anime`. Sonarr's logical anime tag is `anime`, but the qBittorrent category is `animes`.

Radarr and Sonarr root folders must point at final library folders, not torrent folders and not `/srv/data` directly.

### Network and service URLs

- Same-machine app links should use localhost: qBittorrent `localhost:8080`, Radarr `localhost:7878`, Sonarr `localhost:8989`, Prowlarr `localhost:9696`, Byparr `localhost:8191`.
- Same-LAN clients should use shiro LAN IP `192.168.18.7`.
- Tailscale clients may use `shiro`/MagicDNS from ryu and sora because they accept Tailscale DNS.
- Container-to-host callbacks should use `192.168.18.7` unless the container is explicitly configured for host networking.

### qBittorrent

- Module: `hosts/shiro/media/qbittorrent.nix`; WebUI: `http://shiro:8080`; state: `/var/lib/qBittorrent`.
- Categories are Git-owned in `hosts/shiro/service-configs/qbittorrent/categories.json`.
- Nix owns important preferences via `services.qbittorrent.serverConfig`.
- The committed qBittorrent password hash is an accepted LAN/Tailscale-only exception.

### Radarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:7878`.
- Root folder: `/srv/data/media/movies`.
- qBittorrent download client: `localhost:8080`, category `movies`, no Radarr download-client tags.
- Recyclarr profiles include `Movies - 1080p Balanced`, `Movies - 1080p Quality HDR`, `Movies - 2160p Balanced`, `Movies - 2160p Quality`, plus legacy profiles for the previous 1080p Remux and 4K test behavior.

### Sonarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:8989`.
- Root folders: `/srv/data/media/tv` and `/srv/data/media/anime`.
- Tags: `tv` for normal series, `anime` for anime.
- Download clients: `qBittorrent - TV` category `tv` restricted to tag `tv`; `qBittorrent - Animes` category `animes` restricted to tag `anime`.
- Recyclarr profiles include `Series - 1080p Balanced`, `Series - 1080p Quality HDR`, `Series - 2160p Balanced`, `Series - 2160p Quality`, plus legacy profiles for previous series/anime behavior.

### Bazarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:6767`.
- Writes `.srt` sidecar subtitles into Radarr/Sonarr library folders.
- Radarr, Sonarr, and Bazarr use `UMask = "0002"` so the shared `media` group can write sidecars and imports consistently.
- Prefer SRT sidecars for Plex Web/mobile compatibility.

### Prowlarr and Byparr

- Prowlarr module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:9696`.
- Byparr module: `hosts/shiro/media/containers.nix`; local URL: `http://localhost:8191`.
- Prowlarr is the source of truth for indexers. Do not duplicate Prowlarr-managed indexers in Radarr/Sonarr.
- App sync level should be `fullSync` for both Radarr and Sonarr.
- Configure Byparr in Prowlarr as a FlareSolverr-compatible indexer proxy tagged `byparr`, and apply that tag only to indexers that need Cloudflare/DDoS-GUARD solving.

### Recyclarr

- Module: `hosts/shiro/media/recyclarr.nix`; schedule: daily.
- API-key files: `/var/lib/secrets/recyclarr-radarr-api-key` and `/var/lib/secrets/recyclarr-sonarr-api-key`.
- Owns Radarr/Sonarr quality profiles and custom formats. Port manual profile changes back to Nix or they may be overwritten.

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

### Qui

- Module: `hosts/shiro/media/qui.nix`; WebUI: `http://shiro:7476`.
- Optional alternate qBittorrent UI. Auth is intentionally disabled only for LAN/Tailscale CIDRs; remove it if unused.

## State vs Git

Git-owned/declarative: NixOS modules, Recyclarr config, qBittorrent major preferences, qBittorrent categories, and operator docs.

Stateful/WebUI-owned: Radarr, Sonarr, Prowlarr, Bazarr, Plex, Cleanuparr, and Qui databases/configs; Prowlarr indexers; Plex claim/account/library state; Cleanuparr cleanup rules/blacklists.

Ignored local backups: `hosts/shiro/media/config-backups/` stores live databases, API keys, tokens, and cookies and is intentionally ignored.

When investigating problems with the home-server applications, inspect live state on `shiro` over SSH instead of relying only on local backup snapshots. Use the least-invasive live checks available: service logs/status, application APIs, state databases, and container logs. Keep secrets out of responses and Git.

## Service documentation

Before changing WebUI-managed service state, read the matching guide in `hosts/shiro/media/docs/`: `qbittorrent.md`, `radarr.md`, `sonarr.md`, `bazarr.md`, `prowlarr-byparr.md`, `recyclarr.md`, `plex.md`, `cleanuparr.md`, `qui.md`, and `backups.md`.

## Validation checklist

After repository changes, run the smallest relevant checks: `nix eval .#nixosConfigurations.shiro.config.system.stateVersion`, the matching host evals for ryu/sora when touched, and `git diff --check`.

After shiro media changes, also check live services when appropriate with `systemctl status radarr sonarr prowlarr bazarr qbittorrent plex podman-cleanuparr --no-pager` and `sudo podman ps`.

## Commit messages

When asked to commit, use a descriptive title and include a concise explanation of what changed, why it changed, and any migration/runtime impact.
