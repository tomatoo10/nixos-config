# Prowlarr WebUI-managed configuration

Native NixOS manages the Prowlarr service. Prowlarr apps, indexers, indexer
proxies, tags, and sync state are stored in Prowlarr state and should be managed
through the WebUI or a future API provisioning script.

## Apps

Prowlarr should be the source of truth for indexers synced to Arr apps.

- Radarr app:
  - Prowlarr Server: `http://localhost:9696`
  - Radarr Server: `http://localhost:7878`
  - Sync Level: `fullSync`
  - Tags: empty
  - Sync categories: movie categories (`2000` family)
- Sonarr app:
  - Prowlarr Server: `http://localhost:9696`
  - Sonarr Server: `http://localhost:8989`
  - Sync Level: `fullSync`
  - Tags: empty
  - Sync categories: TV categories (`5000` family)
  - Anime sync category: `5070`

## FlareSolverr

FlareSolverr is declared in `hosts/shiro/configuration.nix` as a native service
on port `8191`.

In Prowlarr, add an indexer proxy when shiro is reachable:

- Settings -> Indexers -> Indexer Proxies -> Add -> FlareSolverr
- Name: `FlareSolverr`
- Host: `http://localhost:8191`
- Request Timeout: default `60` seconds unless a specific indexer needs more
- Tags: use a proxy tag such as `flaresolverr`

For each protected indexer, add the same `flaresolverr` tag to that indexer.
Prowlarr only uses the proxy when the proxy tag matches the indexer tag, and
only for Cloudflare/DDoS-GUARD-style challenges.

## Indexers

Do not commit indexer credentials, cookies, API keys, or invite-only tracker
details. Add indexers in Prowlarr, test them there, and let Prowlarr sync them
to Radarr/Sonarr.
