# shiro service configs

This directory contains service configuration that is safe to manage from Git.

## Exported here

- `qbittorrent/qBittorrent.conf.template` — exported qBittorrent settings from shiro. The WebUI password hash is intentionally replaced by `@QBITTORRENT_WEBUI_PASSWORD_PBKDF2@` so no password hash is committed.
- `qbittorrent/categories.json` — exported active qBittorrent category names and save paths: `movies`, `tv`, `animes`, and `unlinked`.

These files are not currently installed by Nix. qBittorrent writes its own config on shutdown, and the WebUI password hash should not be committed. If the server is reinstalled, copy/import these settings as a baseline and set the WebUI password through qBittorrent or a secret mechanism.

## Not committed here

- Cleanuparr stores WebUI configuration, users, API keys, JWT keys, and event state in SQLite databases under `/srv/cleanuparr/config`. Those databases should stay persistent state, not Git files.
- Radarr and Sonarr store most WebUI configuration in SQLite databases under `/var/lib/radarr` and `/var/lib/sonarr`; their `config.xml` files contain API keys. Their quality/profile rules are managed declaratively through Recyclarr in `hosts/shiro/configuration.nix` instead.
