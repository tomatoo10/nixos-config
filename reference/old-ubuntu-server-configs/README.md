# Old Ubuntu Server Configs (Sanitized Reference)

These files were copied from `/home/ak4m3/random/configs` and sanitized before being added here.

They are **reference material only**, not active NixOS configuration. Use them to understand the previous Ubuntu/Docker setup, service ports, paths, feature choices, and app relationships. Do not blindly port them.

Known services represented:

- Recyclarr: `compose.yml`, `compose_1.yml`, `recyclarr.yml`, `settings.yml`
- qBittorrent: `qBittorrent.conf`
- Sonarr/Radarr: `config.xml`, `config_1.xml`
- Bazarr: `config.yaml`
- Overseerr: `settings.json`

Sanitization replaced API keys, passwords/hashes, tokens/secrets, VAPID keys, Plex machine identifiers, LAN IPs, and old home paths where detected. If a future change needs exact live secrets, model them with `sops-nix` instead of committing them here.

Migration rule: prefer improved declarative NixOS/service design over exact reproduction when there is a clear benefit. Explain the trade-off before changing behavior.
