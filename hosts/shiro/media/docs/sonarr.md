# Sonarr

## Nix ownership

- Module: `hosts/shiro/media/arr.nix`
- WebUI: `http://shiro:8989`
- State: `/var/lib/sonarr`
- Service group: `media`
- Service umask: `0002`

Sonarr's database and most WebUI settings are stateful. Recyclarr owns quality profiles and custom formats.

## Root folders and profiles

| Type | Root folder | Profile | Sonarr tag | qBittorrent category |
| --- | --- | --- | --- | --- |
| Normal TV | `/srv/data/media/tv` | `Series - 1080p Remux` | `tv` | `tv` |
| Anime | `/srv/data/media/anime` | `Anime - 1080p Remux` | `anime` | `animes` |

The Sonarr tag is singular `anime`; the qBittorrent category is plural `animes`.

## Download clients

Create two qBittorrent clients:

### qBittorrent - TV

- Host: `localhost`
- Port: `8080`
- Category: `tv`
- Tags/restriction: `tv`

### qBittorrent - Animes

- Host: `localhost`
- Port: `8080`
- Category: `animes`
- Tags/restriction: `anime`

This prevents normal shows and anime from sharing the same qBittorrent category/path.

## Prowlarr integration

Sonarr indexers should be managed by Prowlarr.

In Prowlarr's Sonarr app entry:

- Prowlarr server URL: `http://localhost:9696`
- Sonarr server URL: `http://localhost:8989`
- Sync level: `fullSync`
- Sync categories: TV `5000` family, including anime category `5070` where appropriate

## Add series checklist

1. Choose the correct root folder.
2. Choose the correct Recyclarr-managed profile.
3. Add the matching Sonarr tag.
4. Confirm the matching qBittorrent client is eligible.
5. Search/grab and confirm the qBittorrent category.

If a series has no matching tag, Sonarr may have no eligible download client or may route to the wrong category.
