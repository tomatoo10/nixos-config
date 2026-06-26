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

## Experimental FlareSolverr PR-1300

`hosts/shiro/configuration.nix` also defines a disposable PR-1300 test container:

- Image: `alexfozor/flaresolverr:pr-1300`
- Container port: `8191`
- Host bind: `127.0.0.1:8192`
- Prowlarr URL: `http://localhost:8192`

This should not replace the native FlareSolverr service unless it proves more
reliable. To test it in Prowlarr, add a second Indexer Proxy using the
FlareSolverr proxy type:

- Name: `FlareSolverr PR-1300`
- Host: `http://localhost:8192`
- Request Timeout: `120` to `180` seconds
- Tags: `flaresolverr-pr1300`

Then tag only the problematic test indexer, such as 1337x, with
`flaresolverr-pr1300`.

## Experimental Byparr

`hosts/shiro/configuration.nix` also defines a disposable Byparr test container:

- Image: `ghcr.io/thephaseless/byparr:latest`
- Container port: `8191`
- Host bind: `127.0.0.1:8193`
- Prowlarr URL: `http://localhost:8193`

Byparr exposes a FlareSolverr-compatible API. To test it in Prowlarr, add
another Indexer Proxy using the FlareSolverr proxy type:

- Name: `Byparr`
- Host: `http://localhost:8193`
- Request Timeout: `120` to `180` seconds
- Tags: `byparr`

Then tag only the problematic test indexer, such as 1337x, with `byparr`.

## Indexers

Do not commit indexer credentials, cookies, API keys, or invite-only tracker
details. Add indexers in Prowlarr, test them there, and let Prowlarr sync them
to Radarr/Sonarr.
