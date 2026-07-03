# Sonarr

## Nix ownership

- Module: `hosts/shiro/media/arr.nix`
- WebUI: `http://shiro:8989`
- State: `/var/lib/sonarr`
- Service group: `media`
- Service umask: `0002`

Sonarr's database and most WebUI settings are stateful. Profilarr is the active
profile-management path for normal series.

## Root folders and profiles

| Type | Root folder | Profile | Sonarr tag | qBittorrent category |
| --- | --- | --- | --- | --- |
| Normal TV | `/srv/data/media/tv` | Profilarr-managed series profile | `tv` | `tv` |
| Anime | `/srv/data/media/anime` | `Anime - Legacy 1080p Remux` | `anime` | `animes` |

The Sonarr tag is singular `anime`; the qBittorrent category is plural `animes`.

If Recyclarr is ever re-added for anime, keep ownership split so Profilarr and
Recyclarr never manage the same profile/custom-format set.

## Download clients

Create two qBittorrent clients:

### qBittorrent - TV

- Host: `localhost`
- Port: `8080`
- Category: `tv`
- Tags/restriction: `tv`
- Remove completed downloads: enabled if available
- Remove failed downloads: enabled if available

### qBittorrent - Animes

- Host: `localhost`
- Port: `8080`
- Category: `animes`
- Tags/restriction: `anime`
- Remove completed downloads: enabled if available
- Remove failed downloads: enabled if available

This prevents normal shows and anime from sharing the same qBittorrent category/path.

Do not use the `unlinked` qBittorrent category in Sonarr. It is reserved for
Cleanuparr post-import orphan cleanup, not active downloads.

## Prowlarr integration

Sonarr indexers should be managed by Prowlarr.

In Prowlarr's Sonarr app entry:

- Prowlarr server URL: `http://localhost:9696`
- Sonarr server URL: `http://localhost:8989`
- Sync level: `fullSync`
- Sync categories: TV `5000` family, including anime category `5070` where appropriate
- Anime standard-format search: enabled if normal TV categories should also be
  searched for anime series.

## Add series checklist

1. Choose the correct root folder.
2. Choose the correct Profilarr-managed profile for normal TV or the retained anime profile for anime.
3. Add the matching Sonarr tag.
4. Confirm the matching qBittorrent client is eligible.
5. Search/grab and confirm the qBittorrent category.

If a series has no matching tag, Sonarr may have no eligible download client or may route to the wrong category.

## Custom format upgrades

Profilarr-managed profiles use both quality cutoffs and custom-format score
cutoffs. A series can already have files and still be considered upgradeable if
the imported file score is below the profile cutoff. Before relaxing a broad
negative custom format, inspect which custom format matched and whether it is a
real release problem or only an acceptable local exception.

After an episode/season upgrade, old torrent payloads may become
`unlinked` if they no longer have hardlinks to active library files. Cleanuparr
can move orphaned payloads to `unlinked`; the live deletion rule then removes
only public unlinked torrents after the shorter review window. Private tracker
torrents should remain excluded from aggressive deletion.
