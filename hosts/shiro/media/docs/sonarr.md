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
| Anime | `/srv/data/media/anime` | `Anime - 1080p Efficient (shiro)` | `anime` | `animes` |

The Sonarr tag is singular `anime`; the qBittorrent category is plural `animes`.

Anime uses a retained Sonarr-owned profile tuned for shiro's direct-play-first
constraints. It keeps TRaSH anime BD/WEB tiers dominant, but adds small
x265/HEVC tie-breaker scores and negative HDTV scores so high-bitrate HDTV x264
fallbacks are less likely to beat playable WEB/BD releases. If Recyclarr or
Profilarr is ever re-added for anime, keep ownership split so multiple managers
never sync the same profile/custom-format set.

Current anime profile policy:

- Profile: `Anime - 1080p Efficient (shiro)`.
- Minimum custom-format score: `100`.
- Custom-format cutoff: `1000`.
- Minimum upgrade score step: `25`.
- Keep hard blocks for `BR-DISK`, LQ formats/groups, `Extras`, `AV1`,
  `Anime Raws`, `Dubs Only`, `VOSTFR`, `Language: Not Original`, and
  `Not Original or English`.
- Keep anime tiers dominant: Anime BD Tier 01-08 score `1400` down to `700`;
  Anime WEB Tier 01-06 score `600` down to `100`.
- Add only small direct-play/network tie-breakers: `x265 (HD)` `+25`, 1080p
  HEVC WEB/Bluray tier formats `+25`, and keep the generic `x265`/`h265`,
  `x265 (WEB)`, `x265 (Bluray)`, and `x265 (no HDR/DV)` formats neutral. Codec
  efficiency must not be enough to make a weak or wrong-language release pass.
- Keep `Season Pack` neutral in this default anime profile. Do not globally
  hard-reject packs: they can be useful for complete/archive anime, but they
  should not beat better episode releases just for being a pack.
- Penalize HDTV fallback: `1080p HDTV` `-400`, HDTV tiers `-250`/`-350`/`-450`;
  720p HDTV gets smaller negative scores.

This profile intentionally does not prefer x265/HEVC over everything. A stronger
anime BD/WEB tier should beat a weak efficient release, and x265/HEVC should be a
tie-breaker only. The goal is to avoid releases that are technically
higher-bitrate x264/HDTV or weak wrong-language HEVC packs but do not play
smoothly over shiro's current Wi-Fi/disk path.

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

Quality Definitions are also Profilarr-owned through Media Management sync. They
are hard size gates and run before custom-format scoring. If high-scoring anime
releases are rejected for minimum/maximum size, first check the Profilarr Sonarr
Media Management sync state. The intended shiro/Dictionarry Sonarr definitions
are permissive for efficient HEVC/anime: `minSize = 0`, unlimited `maxSize`, and
`preferredSize = 990`.

After an episode/season upgrade, old torrent payloads may become
`unlinked` if they no longer have hardlinks to active library files. Cleanuparr
can move orphaned payloads to `unlinked`; the live deletion rule then removes
only public unlinked torrents after the shorter review window. Private tracker
torrents should remain excluded from aggressive deletion.
