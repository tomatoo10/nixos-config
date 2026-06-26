# Prowlarr WebUI-managed configuration

Native NixOS manages the Prowlarr service. Prowlarr apps, indexers, indexer
proxies, tags, and sync state are stored in Prowlarr state and should be managed
through the WebUI or a future API provisioning script.

Do not commit Prowlarr databases, API keys, cookies, private tracker credentials,
or invite-only tracker details.

## General

- **App URL**: `http://localhost:9696`
- **Bind address**: `*` — declared in `hosts/shiro/media/arr.nix` so LAN clients can reach Prowlarr.
- **Prowlarr state path**: `/var/lib/private/prowlarr` on NixOS because the service uses private state.

## Apps

Prowlarr should be the source of truth for indexers synced to Arr apps.

- Radarr app:
  - **Implementation**: Radarr
  - **Prowlarr Server URL**: `http://localhost:9696`
  - **Radarr Server URL**: `http://localhost:7878`
  - **Sync Level**: `fullSync` — Prowlarr fully manages synced indexer definitions in Radarr.
  - **Tags**: empty — Prowlarr app tags are not Sonarr download-routing tags.
  - **Sync categories**: movie categories (`2000` family)
- Sonarr app:
  - **Implementation**: Sonarr
  - **Prowlarr Server URL**: `http://localhost:9696`
  - **Sonarr Server URL**: `http://localhost:8989`
  - **Sync Level**: `fullSync` — Prowlarr fully manages synced indexer definitions in Sonarr.
  - **Tags**: empty — do not confuse these with Sonarr `tv`/`anime` tags.
  - **Sync categories**: TV categories (`5000` family)
  - **Anime sync category**: `5070`

## Byparr

Byparr is declared in `hosts/shiro/configuration.nix` as the only configured
Cloudflare/DDoS-GUARD solver. It exposes a FlareSolverr-compatible API on
localhost port `8191`.

In Prowlarr, add one indexer proxy:

- Settings -> Indexers -> Indexer Proxies -> Add -> FlareSolverr
- **Name**: `FlareSolverr - Byparr` or `Byparr`
- **Implementation**: FlareSolverr — Byparr exposes a FlareSolverr-compatible API.
- **Host**: `http://localhost:8191`
- **Request Timeout**: `120` to `180` seconds
- **Tags**: `byparr`

For each protected indexer, add the same `byparr` tag to that indexer. Prowlarr
only uses the proxy when the proxy tag matches the indexer tag, and only for
Cloudflare/DDoS-GUARD-style challenges.

## Indexers

Add indexers in Prowlarr, test them there, and let Prowlarr sync them to
Radarr/Sonarr.

Notes:

- Use the `byparr` tag only on indexers that need Cloudflare/DDoS-GUARD solving.
- Some indexers are external reliability problems, not local config problems.
- `asnet.pw`/AniSource is IPv6-only from shiro; Prowlarr may disable IPv6 when IPv4 is available, so it may remain problematic.
- `8000 (Other)` is an app sync category, not a tag.
