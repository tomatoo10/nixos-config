# Radarr

## Nix ownership

- Module: `hosts/shiro/media/arr.nix`
- WebUI: `http://shiro:7878`
- State: `/var/lib/radarr`
- Service group: `media`
- Service umask: `0002`

Radarr's database and most WebUI settings are stateful. Recyclarr is currently
disabled while Profilarr is being tested; if re-enabled, Recyclarr owns only the
legacy quality profiles and their custom formats.

## Required media setup

- Root folder: `/srv/data/media/movies`
- Do not use `/srv/data`, `/srv/data/torrents`, or any qBittorrent category path as a root folder.
- Legacy 1080p profile: `Movies - Legacy 1080p Remux + WEB`
- Legacy 4K profile: `Movies - Legacy 2160p UHD Bluray + WEB`

## Download client

Add one qBittorrent client:

- Name: `qBittorrent`
- Host: `localhost`
- Port: `8080`
- Category: `movies`
- Remove completed downloads: enabled if available
- Remove failed downloads: enabled if available
- Tags: none

Using localhost keeps same-machine traffic off LAN/Tailscale.

Do not use the `unlinked` qBittorrent category in Radarr. `unlinked` is reserved
for Cleanuparr to stage torrent payloads that no longer have hardlinks to active
library files after imports, upgrades, or deletions.

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

## Custom format upgrades

Recyclarr-managed profiles use both a quality cutoff and a custom-format score
cutoff. A movie can meet the quality cutoff and still remain upgradeable if its
current file's custom-format score is below the profile cutoff.

Observed example: `Tigole` is included in TRaSH's `LQ` release-group custom
format. A 4K file from that group can import and play correctly, but Radarr still
scores it as LQ after import. If the profile's custom-format cutoff is higher
than that imported score, Radarr may grab another release during a manual or
automatic search even though the movie already has a downloaded file.

Do not relax `LQ` globally without checking the matched custom format first;
doing so affects all releases matched by the TRaSH LQ list, not just one movie.

When Radarr imports an upgrade, it replaces the library file. The old torrent
payload may still exist in qBittorrent until completed-download handling or
Cleanuparr removes it. If the old payload is no longer hardlinked to the library,
Cleanuparr can classify it as `unlinked`; the live deletion rule then removes
only public unlinked torrents after the shorter review window. Private tracker
torrents should remain excluded from aggressive deletion.

## Troubleshooting

- If imports fail, check `/srv/data/media/movies` permissions and that Radarr is in group `media`.
- If downloads go to the wrong folder, check Radarr qBittorrent category and qBittorrent category JSON.
- If profiles disappear/change, check Recyclarr sync logs and port the desired change into `hosts/shiro/media/recyclarr.nix`.
