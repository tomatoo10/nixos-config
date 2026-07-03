# Qui

## Nix ownership

- Module: `hosts/shiro/media/qui.nix`
- WebUI: `http://shiro:7476`
- State: `/var/lib/qui`
- Secret file: `/var/lib/secrets/qui-session.txt`
- Status: configured but disabled

Qui is an optional alternate qBittorrent UI. It is currently disabled because the stock qBittorrent WebUI is enough.

## Security model

When enabled, auth is intentionally disabled only for trusted CIDRs:

- `192.168.18.0/24`
- `100.64.0.0/10`

Do not expose Qui publicly. If the network trust boundary changes, either enable auth or keep Qui disabled.

## When to keep it

Keep Qui only if you actively use it instead of qBittorrent's built-in WebUI. It costs memory and expands the trusted-network UI surface.

Qui should point at the same qBittorrent instance and categories documented in
`qbittorrent.md`. Do not use Qui to create alternate category names or save
paths; Radarr, Sonarr, and Cleanuparr depend on `movies`, `tv`, `animes`, and
`unlinked` having their documented meanings.

If Qui is only used for quick inspection, prefer making durable qBittorrent
category/preference changes through the Git-owned qBittorrent config path and
then rebuilding/restarting shiro.

## Restore notes

Restore `/var/lib/qui` from the ignored config backup if needed, then restart `qui.service`.
