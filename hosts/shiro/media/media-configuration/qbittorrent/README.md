# qBittorrent declarative configuration

Native NixOS manages the service, ports, firewall, user/group, and `/srv/data`
directories. qBittorrent's `qBittorrent.conf` is declared via
`services.qbittorrent.serverConfig` in `hosts/shiro/media/qbittorrent.nix`.
Categories are also Nix/Git-owned: `categories.json` is installed before
qBittorrent starts. Edit the JSON file in Git, not the WebUI, when changing
categories.

The live config file is:

```text
/var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf
```

The exact exported baseline is stored at
`hosts/shiro/service-configs/qbittorrent/qBittorrent.conf`. It intentionally
contains the current WebUI password hash because shiro's qBittorrent WebUI is
limited to LAN/Tailscale. The sanitized template keeps the same settings with
`WebUI\Password_PBKDF2` replaced by a placeholder.

## Nix-owned settings

- `Session\DefaultSavePath`: `/srv/data/torrents/` — default completed download root.
- `Session\TempPath`: `/srv/data/torrents/incomplete/` — incomplete download root.
- `Downloads\SavePath`: `/srv/data/torrents/` — legacy/compat save path.
- `Downloads\TempPath`: `/srv/data/torrents/incomplete/` — legacy/compat temp path.
- `Session\MaxActiveDownloads`: `1` — conservative limit for the old laptop.
- `Session\MaxActiveUploads`: `-1` — unlimited upload slots.
- `Session\MaxActiveTorrents`: `-1` — unlimited active torrents except download cap.
- `Session\GlobalDLSpeedLimit`: `14100` — global download cap in KiB/s.
- `Session\GlobalUPSpeedLimit`: `13350` — global upload cap in KiB/s.
- `Session\SlowTorrentsDownloadRate`: `5000` — slow torrent threshold.
- `Session\AddTrackersEnabled`: `true` — add public trackers to new torrents.
- `Session\AdditionalTrackersURL`: cf.trackerslist.com `best.txt`
  (`https://cf.trackerslist.com/best.txt`)
- `Session\AdditionalTrackers`: currently 77 trackers from that source.
- `WebUI\AuthSubnetWhitelistEnabled`: `true` — allows trusted subnets to use the API without a password.
- `WebUI\AuthSubnetWhitelist`:
  - `127.0.0.1/32` and `::1/128` for local API access.
  - `100.64.0.0/10` for Tailscale clients.
  - `192.168.18.0/24` for LAN clients.
  - `10.88.0.0/16` for Podman containers such as Cleanuparr.
- `WebUI\ServerDomains`: `*` — required for LAN/Tailscale hostnames/IPs.

## Nix-owned categories

`hosts/shiro/service-configs/qbittorrent/categories.json` defines these
categories and is copied into qBittorrent's config directory before the service
starts:

  - `movies` → `/srv/data/torrents/movies`
  - `tv` → `/srv/data/torrents/tv`
  - `animes` → `/srv/data/torrents/animes`
  - `unlinked` → `/srv/data/torrents/unlinked`

The singular torrent category/path `anime` is stale; use `animes` everywhere.
