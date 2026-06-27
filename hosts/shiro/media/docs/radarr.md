# Radarr

## Nix ownership

- Module: `hosts/shiro/media/arr.nix`
- WebUI: `http://shiro:7878`
- State: `/var/lib/radarr`
- Service group: `media`
- Service umask: `0002`

Radarr's database and most WebUI settings are stateful. Recyclarr owns quality profiles and custom formats.

## Required media setup

- Root folder: `/srv/data/media/movies`
- Do not use `/srv/data`, `/srv/data/torrents`, or any qBittorrent category path as a root folder.
- Standard profile: `Movies - 1080p Remux`
- Optional test profile: `Movies - 4K Test`

## Download client

Add one qBittorrent client:

- Name: `qBittorrent`
- Host: `localhost`
- Port: `8080`
- Category: `movies`
- Remove completed downloads: enabled if available
- Tags: none

Using localhost keeps same-machine traffic off LAN/Tailscale.

## Prowlarr integration

Radarr indexers should be managed by Prowlarr, not duplicated manually in Radarr.

In Prowlarr's Radarr app entry:

- Prowlarr server URL: `http://localhost:9696`
- Radarr server URL: `http://localhost:7878`
- Sync level: `fullSync`
- Sync categories: movie categories, normally the `2000` family

## Add movie checklist

1. Choose root folder `/srv/data/media/movies`.
2. Choose a Recyclarr-managed profile.
3. Monitor the movie.
4. Search/grab.
5. Confirm qBittorrent category is `movies`.

## Troubleshooting

- If imports fail, check `/srv/data/media/movies` permissions and that Radarr is in group `media`.
- If downloads go to the wrong folder, check Radarr qBittorrent category and qBittorrent category JSON.
- If profiles disappear/change, check Recyclarr sync logs and port the desired change into `hosts/shiro/media/recyclarr.nix`.
