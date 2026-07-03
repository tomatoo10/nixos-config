# shiro service configs

This directory contains exported service configuration used as rebuild/reinstall
baseline material for shiro.

## Exported here

- `qbittorrent/qBittorrent.conf` — exact exported qBittorrent settings from shiro, including the current WebUI password hash. This is intentional for the current LAN/Tailscale-only setup and feeds the declarative `services.qbittorrent.serverConfig` in `hosts/shiro/media/qbittorrent.nix`.
- `qbittorrent/qBittorrent.conf.template` — sanitized copy with `WebUI\Password_PBKDF2` replaced by `@QBITTORRENT_WEBUI_PASSWORD_PBKDF2@` for reference.
- `qbittorrent/categories.json` — exported active qBittorrent category names and save paths: `movies`, `tv`, `animes`, and `unlinked`.

Nix owns `qBittorrent.conf` through the qBittorrent module. Nix also owns
`categories.json` and installs it before qBittorrent starts. Do not edit
categories in the qBittorrent WebUI unless you export/update this JSON file too.

## Not committed here

- Cleanuparr stores WebUI configuration, users, API keys, JWT keys, and event state in SQLite databases under `/srv/cleanuparr/config`. Those databases should stay persistent state, not Git files.
- Radarr and Sonarr store most WebUI configuration in SQLite databases under `/var/lib/radarr` and `/var/lib/sonarr`; their `config.xml` files contain API keys. Current quality/profile management is handled by Profilarr state, not by files in this directory.
