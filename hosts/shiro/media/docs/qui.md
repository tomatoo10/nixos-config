# Qui

## Status

Qui is removed from the active NixOS configuration. There is no current
`hosts/shiro/media/qui.nix` module, WebUI, state directory, or session secret
requirement.

Qui was an optional alternate qBittorrent UI. It was removed because the stock
qBittorrent WebUI is enough and Qui broadened the trusted-network UI surface.

## Security model

If Qui is re-added, do not expose it publicly. The old configuration disabled
auth only for trusted CIDRs:

- `192.168.18.0/24`
- `100.64.0.0/10`

If the network trust boundary changes, either enable auth or keep Qui removed.

## When to re-add it

Re-add Qui only if you actively need it instead of qBittorrent's built-in WebUI.
It costs memory and expands the trusted-network UI surface.

Qui should point at the same qBittorrent instance and categories documented in
`qbittorrent.md`. Do not use Qui to create alternate category names or save
paths; Radarr, Sonarr, and Cleanuparr depend on `movies`, `tv`, `animes`, and
`unlinked` having their documented meanings.

If Qui is only used for quick inspection, prefer making durable qBittorrent
category/preference changes through the Git-owned qBittorrent config path and
then rebuilding/restarting shiro.

## Re-add notes

Recreate a `hosts/shiro/media/qui.nix` module, add it to
`hosts/shiro/configuration.nix`, evaluate shiro, rebuild, and then start
`qui.service`. Restore `/var/lib/qui` from the ignored config backup only if old
Qui state is still needed.
