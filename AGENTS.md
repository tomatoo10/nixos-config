# NixOS Configuration Agent Guide

This repository manages the user's NixOS machines and the shiro home-server media stack. The active hosts are `ryu`, `sora`, and `shiro`; older migration notes are historical only and must not be treated as source of truth.

## Non-negotiable engineering policy

- Do not run `nixos-rebuild build`, `nixos-rebuild switch`, `nh os switch`, or
  other rebuild/switch commands unless the user explicitly asks for that command
  to be executed. Validate repository changes with focused `nix eval` checks,
  `git diff --check`, and reviewable diffs; then give the user the exact remote
  rebuild/switch command to run.
- Do not introduce hacks, monkey patches, duct tape, or partial workarounds.
- Prefer robust, clear, maintainable designs over short-term convenience.
- Backwards compatibility is not important when preserving it would keep a bad design. Fix the design instead.
- Keep secrets out of Git unless the repository explicitly documents an accepted exception.
- If the requested result cannot be done cleanly, stop and explain the blocker.
- If a fix has uncertain side effects, looks workaround-like, or has multiple
  plausible clean approaches, present the options and ask before applying it.
- User requests can be technically wrong or point toward a worse design. When
  there is a cleaner, safer, or more maintainable approach, push back, explain
  the tradeoff, and ask before implementing the inferior approach.
- Do not treat the user as automatically authoritative on technical direction.
  Respect their goals, but ask targeted questions when unsure and explain when a
  requested approach looks fragile, unsafe, or less maintainable than an
  alternative.
- After every change, report anything fragile, uncertain, or workaround-like.

## Repository layout

- `flake.nix` — host inventory, inputs, and NixOS system construction.
- `hosts/` — host-specific configuration: `ryu`, `sora`, and `shiro`.
- `hosts/shiro/{networking,system,media}/` — shiro section directories with
  `default.nix` entrypoints for host composition.
- `modules/` — reusable NixOS modules grouped into `core`, `boot`, `desktop`, `hardware`, `virtualisation`, and `gaming`.
- `home/` — Home Manager program and desktop configuration.
- `themes/` — Stylix theme modules.
- `hosts/shiro/media/docs/` — operator setup and restore docs for shiro media apps, including Pi-hole.
- `hosts/shiro/service-configs/` — Git-owned exported service config fragments.

## Host policy

- `ryu`: main desktop. Firewall is disabled for HTB. Tailscale is enabled but must not accept DNS; home DNS should come from DHCP/Pi-hole: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`.
- `sora`: laptop. OpenSSH is intentionally disabled. Tailscale is enabled but must not accept DNS; home DNS should come from DHCP/Pi-hole and away-from-home DNS should come from the active network unless a deliberate conditional/Tailscale DNS design is added later: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`.
- `shiro`: home server at LAN IP `192.168.18.7`; use `ssh shiro.lan` for live checks. The internal Intel AC 3160 Wi-Fi radio with MAC `9c:da:3e:4a:41:0b` is the authoritative LAN path, should connect to the 5GHz `Vania_5G` network, and is renamed to `shiro-lan`; the USB Realtek 2.4GHz adapter with MAC `00:e0:4d:0b:47:8d` is intentionally disabled because a July 2026 Plex buffering diagnosis showed severe LAN latency spikes on the Realtek path while Intel 5GHz was stable. IPv6 stays enabled: the router advertises ULA `fd7a:c324:7131::/64` and has IPv6 forwarding firewall control enabled, while shiro also source-restricts private service ports in its host firewall. Tailscale is enabled but should not accept DNS: `extraSetFlags = ["--ssh=true" "--accept-dns=false"]`. Docker is not enabled. Podman-backed `virtualisation.oci-containers` is used only for auxiliary services. `zramSwap` is intentionally enabled for low-memory resilience. Pi-hole runs natively on `192.168.18.7:53` and `192.168.18.7:8081`.

## shiro media stack contract

The active stack is native Radarr, Sonarr, Bazarr, Prowlarr, qBittorrent, Plex, and Pi-hole, plus Podman containers for Cleanuparr, Byparr, and Profilarr. Qui and Recyclarr were removed because Profilarr and the stock qBittorrent WebUI are the active paths. Readarr is not enabled, but books paths/categories are scaffolded for possible future use. Overseerr and Cloudflare Tunnel are scaffolded but disabled. Keep all apps consistent when changing paths, tags, categories, cleanup rules, DNS, or download-client routing.

### Playback constraints and client targets

- `shiro` runs on an old compact notebook and must be treated as a **direct-play-first** Plex server.
- Do not assume `shiro` can handle video transcoding, audio transcoding, or subtitle burn-in at acceptable performance.
- If a Plex client buffers while Plex logs still say `Direct play OK`, do not assume a codec problem. First correlate Plex delivery rate with qBittorrent activity, disk IO pressure, and client reconnect/range-retry patterns. In a July 2026 iPhone anime buffering case, playback was direct play with no transcode, but Plex only delivered about 3.4 Mbps for a ~7.8 Mbps file while `/srv/data` disk IO pressure stayed high; the likely bottleneck was disk/local file serving latency rather than video compatibility.
- Avoid media-selection strategies that depend on server-side transcoding for compatibility.
- Prefer formats that direct play reliably on the main clients: `ryu`, `sora`, the ThinkPad T14 Gen 1 AMD, and iPhone 13.
- Prefer external `.srt` sidecar subtitles. Embedded bitmap subtitles such as PGS/VobSub are high risk because they often force Plex to burn subtitles into the video.
- When tuning Radarr/Sonarr/Bazarr/Profilarr for `shiro`, optimize first for smooth playback and subtitle compatibility, then for absolute quality.

### Filesystem layout

- Shared data root: `/srv/data`
- Final media libraries: movies `/srv/data/media/movies`, TV `/srv/data/media/tv`, anime `/srv/data/media/anime`, books `/srv/data/media/books`.
- qBittorrent download root: `/srv/data/torrents`.
- qBittorrent incomplete path: `/srv/data/torrents/incomplete`.
- Active qBittorrent category paths: `movies` -> `/srv/data/torrents/movies`, `tv` -> `/srv/data/torrents/tv`, `animes` -> `/srv/data/torrents/animes`, `books` -> `/srv/data/torrents/books`, `unlinked` -> `/srv/data/torrents/unlinked`, `dead-torrents` -> `/srv/data/torrents/dead-torrents`.

Do not use the singular torrent category/path `anime`. Sonarr's logical anime tag is `anime`, but the qBittorrent category is `animes`.
`dead-torrents` is reserved for Cleanuparr quarantine / dead torrent handling
and must not be used for Arr download-client routing.

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

- Module: `hosts/shiro/media/qbittorrent/default.nix`; WebUI: `http://shiro:8080`; state: `/var/lib/qBittorrent`.
- Categories are Git-owned in `hosts/shiro/service-configs/qbittorrent/categories.json`.
- Nix owns important preferences via `services.qbittorrent.serverConfig`.
- The committed qBittorrent password hash is an accepted LAN/Tailscale-only exception.

### Radarr

- Module: `hosts/shiro/media/arr.nix`; WebUI: `http://shiro:7878`.
- Root folder: `/srv/data/media/movies`.
- qBittorrent download client: `localhost:8080`, category `movies`, no Radarr download-client tags.
- Profilarr is the active profile-management path for Radarr.
- Radarr can fail imports when torrent/internal filenames are localized or otherwise unparseable even if the movie is correct. A July 2026 failure for LOTR Fellowship Extended used a Russian/internal folder name (`01 - Властелин колец...`), Radarr logged `Unable to parse file`, and Cleanuparr later deleted it after `FailedImport` strikes. Prefer parseable English release names with title/year/edition/quality in the torrent and file names.

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

#### July 2026 Arr/Prowlarr search reliability plan

- Current issue: Radarr/Sonarr searches are noisy because Prowlarr has several
  public indexers that repeatedly fail, become temporarily disabled, and still
  sync into Arr. This reduces useful candidates and makes searches slower/noisier.
  Recent long-running failures included `1337x`, `BigFANGroup`, `DaMagNet`,
  `BTdirectory`, `EZTV`, `Internet Archive`, `kickasstorrents.ws`, and `Uindex`;
  short-term failures included `Bangumi Moe`, `MegaPeer`, `nekoBT`, and
  `Tokyo Toshokan`. Tokyo Toshokan showed Cloudflare/origin `522` and parse/error
  responses; Internet Archive timed out; some others returned forbidden/proxy
  failures. qBittorrent itself was up, with one metadata-only anime torrent stuck
  in `metaDL`, so the main reliability problem is indexer quality, not the
  download client being down.
- First step is read-only diagnosis, not blind reconfiguration: inspect Prowlarr
  health/indexer status, proxy/tag settings, app sync settings, and recent logs;
  inspect Radarr/Sonarr health and synced indexer lists; inspect qBittorrent state.
  Do not trigger public copyrighted searches, grabs, deletes, or rebuilds while
  diagnosing.
- Repair-first direction: classify each failing indexer by failure mode before
  disabling it. Cloudflare/DDoS-GUARD challenge failures may be fixable by
  applying the `byparr` tag; rate-limit/noise failures may be improved with
  per-indexer Query Limit / Grab Limit / Limits Unit settings; parser/site markup
  failures may need a Prowlarr/Cardigann definition update. Dead origins,
  persistent 5xx/522 responses, persistent forbidden responses, or semantically
  broken results are not cleanly fixed by proxying and should be disabled if they
  keep polluting Arr health after repair attempts.
- If disabling becomes necessary, disable in Prowlarr, then let Prowlarr full-sync
  the cleaned indexer set to Radarr and Sonarr. Prefer keeping reliable
  anime/general sources enabled over keeping a large list of dead public mirrors.
  Treat this as WebUI/API-owned live state, not Nix-owned configuration.
- Byparr should not be applied globally. Keep the FlareSolverr-compatible proxy
  only on indexers that genuinely need Cloudflare/DDoS-GUARD solving. If an
  indexer fails because its origin is down, banned, forbidden, or semantically
  broken, proxying it is not a clean fix; disable it instead.
- Current repair-first action matrix: keep `byparr` on Cloudflare-marked indexers
  that are still plausibly useful (`1337x`, `BTdirectory`, `EZTV`,
  `kickasstorrents.ws`, `MegaPeer`, `Uindex`) while testing/tuning them; consider
  adding `byparr` only if logs show an actual Cloudflare challenge. Do not add
  `byparr` to `Tokyo Toshokan` unless failures change from origin `522`/parse
  errors into challenge failures. Avoid blunt low per-day Query Limits on useful
  TV/anime indexers: a single Sonarr season or episode replacement can generate
  many alias/category requests, so daily caps can hide candidates later in the
  day. Prefer app-profile scoping first, and use moderate per-hour Query Limits
  only for clearly noisy low-value public mirrors. Internet Archive timeout
  failures should be treated as slow-origin/rate-limit candidates first, but
  disabled if they continue to time out.
- Live repair-first tuning applied July 2026: all affected indexers remained
  enabled, existing `byparr` tags were preserved, Grab Limits stayed unset, and
  Prowlarr Query Limits were set hourly: `1337x` 60/hour, `EZTV` 60/hour,
  `kickasstorrents.ws` 60/hour, `MegaPeer` 60/hour, `Uindex` 60/hour,
  `BTdirectory` 30/hour, `BigFANGroup` 30/hour, `DaMagNet` 30/hour, `nekoBT`
  30/hour, `Bangumi Moe` 30/hour, `Internet Archive` 12/hour, and
  `Tokyo Toshokan` 12/hour. Known-good anime sources such as `Nyaa.si`,
  `SubsPlease`, `Shana Project`, `Mikan`, and `ACG.RIP` were left uncapped.
  Updating broken indexers through the API may hang if Prowlarr validates/tests
  the indexer; use `PUT /api/v1/indexer/{id}?forceSave=true` with the full
  indexer resource when changing only settings such as Query Limit / Limits Unit.
  `forceSave` avoids the validation path but does not fix broken origins.
- Preserve Prowlarr as source of truth: do not manually edit duplicated indexers
  in Radarr/Sonarr except to verify sync results or recover from failed sync.
  After changing Prowlarr indexers, verify Arr health clears or improves and that
  synced indexer counts/settings match expectations.
- Before applying state changes, explain the planned indexer limit/proxy-tag/
  disable changes to the user and get confirmation. After applying, verify with
  Prowlarr health/indexer status, Radarr/Sonarr health, and service status. Do
  not perform automatic searches/grabs as validation unless the user explicitly
  asks.

### Profilarr

- Profilarr is the main profile-management experiment for Radarr/Sonarr at `http://shiro:6868` with config in `/srv/profilarr/config`.
- Profilarr manages/syncs Radarr/Sonarr profiles, custom formats, scores, and
  media-management settings such as naming, media settings, and quality
  definitions. It does not itself choose or upgrade releases at download time.
  Radarr/Sonarr still make grab/import/upgrade decisions from their state and
  configured profiles/quality definitions.
- Profilarr media-management sync must be enabled and run per Arr instance for
  quality definitions to apply. In July 2026, Sonarr was rejecting many anime
  releases for minimum size because Profilarr's Sonarr media-management sync had
  been effectively stale/manual: Dictionarry's selected `Sonarr` quality
  definitions were permissive (`minSize = 0`, unlimited `maxSize`,
  `preferredSize = 990`), but live Sonarr still had strict minimums such as
  `Bluray-1080p = 50.4 MB/min`. Enabling `on_pull` for Sonarr Media Management
  and running the Media Management sync queued `arr.sync.mediaManagement`, which
  updated all 22 Sonarr quality definitions successfully.
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
- Cleanuparr Seeker can trigger missing/cutoff/custom-format searches through Arr state and profiles, and can trigger replacement searches after queue deletion. If strict Arr-only search ownership is desired, disable Seeker search rather than trying to make Cleanuparr score releases independently.

## Package update notes

- Be careful updating only `nixpkgs` while `home-manager` follows it. A July 2026 update from nixpkgs rev `567a49d1913ce81ac6e9582e3553dd90a955875f` to `241313f4e8e508cb9b13278c2b0fa25b9ca27163` made `nixos-rebuild build --flake .#shiro` fail in `bat-0.26.1-fish-completions` because fish 4.8 no longer installed `share/fish/tools/create_manpage_completions.py` at the path Home Manager expected.
- Clean fixes for that Fish completion failure are: update to a Home Manager/nixpkgs revision containing the Fish completion generator fix, or as a temporary explicit policy set `programs.fish.generateCompletions = false;` in the relevant NixOS/Home Manager Fish config. Do not patch store paths or pin random package internals.

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
