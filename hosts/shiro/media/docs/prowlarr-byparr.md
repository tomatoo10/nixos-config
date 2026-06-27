# Prowlarr and Byparr

## Nix ownership

- Prowlarr module: `hosts/shiro/media/arr.nix`
- Prowlarr WebUI: `http://shiro:9696`
- Prowlarr state: `/var/lib/private/prowlarr`
- Byparr module: `hosts/shiro/media/containers.nix`
- Byparr local URL: `http://localhost:8191`

Prowlarr indexers, credentials, cookies, apps, tags, and proxy rows are stateful WebUI/API data.

## Apps

Create apps for Radarr and Sonarr.

### Radarr app

- Prowlarr server URL: `http://localhost:9696`
- Radarr server URL: `http://localhost:7878`
- API key: from Radarr WebUI
- Sync level: `fullSync`
- Categories: movie categories, normally the `2000` family. Current live setup
  includes `2000`, `2010`, `2020`, `2030`, `2040`, `2045`, `2050`, `2060`,
  `2070`, `2080`, `2090`, and `8000`.
- Reject blocklisted torrent hashes while grabbing: currently disabled for
  Radarr.

### Sonarr app

- Prowlarr server URL: `http://localhost:9696`
- Sonarr server URL: `http://localhost:8989`
- API key: from Sonarr WebUI
- Sync level: `fullSync`
- Categories: TV categories, normally the `5000` family. Current live setup
  includes `5000`, `5010`, `5020`, `5030`, `5040`, `5045`, `5050`, `5090`, and
  `8000`.
- Anime categories: `5070` and `8000`.
- Anime standard-format search: enabled.
- Reject blocklisted torrent hashes while grabbing: currently enabled for Sonarr.

Do not manually duplicate Prowlarr-managed indexers inside Radarr/Sonarr.

## Byparr proxy

Byparr is used as the only Cloudflare/DDoS-GUARD solver.

In Prowlarr, add an indexer proxy:

- Type/implementation: FlareSolverr-compatible
- Name: `FlareSolverr - Byparr` or similar
- Host: `http://localhost:8191`
- Timeout: around 60 seconds
- Tag: `byparr`

Apply the `byparr` tag only to indexers that actually need Cloudflare/DDoS-GUARD solving. Do not apply it globally; it adds latency and can fail on sites that do not need solving.

Current live proxy state:

- Indexer proxy: `FlareSolverr - Byparr`
- Host: `http://localhost:8191/`
- Timeout: `60s`
- Tag: `byparr`

Only apply the `byparr` tag after testing that an indexer fails without the
proxy and succeeds with it. If an indexer starts failing through Byparr, first
remove the tag and retest directly before changing global networking or proxy
settings.

## Indexer rules

- Prowlarr is source of truth.
- Prefer fewer reliable indexers over many noisy broken ones.
- Remove or disable indexers that repeatedly fail, 429, or require unsupported network behavior.
- Some failures are external/indexer-specific and should not trigger local architecture changes.

Known caveat: some indexers may be IPv6-only or otherwise incompatible with Prowlarr's network stack. Do not disable IPv4 globally just to make one indexer work.

## Troubleshooting

- Prowlarr logs/state: `/var/lib/private/prowlarr`
- Byparr container logs: `sudo podman logs byparr`
- Confirm Byparr is local-only: `127.0.0.1:8191:8191`
- If an indexer fails through Byparr, test it without proxy and with proxy before changing global settings.
