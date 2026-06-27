# Qui

## Nix ownership

- Module: `hosts/shiro/media/qui.nix`
- WebUI: `http://shiro:7476`
- State: `/var/lib/qui`
- Secret file: `/var/lib/secrets/qui-session.txt`

Qui is an optional alternate qBittorrent UI.

## Security model

Auth is intentionally disabled only for trusted CIDRs:

- `192.168.18.0/24`
- `100.64.0.0/10`

Do not expose Qui publicly. If the network trust boundary changes, either enable auth or remove Qui.

## When to keep it

Keep Qui only if you actively use it instead of qBittorrent's built-in WebUI. It costs memory and expands the trusted-network UI surface.

## Restore notes

Restore `/var/lib/qui` from the ignored config backup if needed, then restart `qui.service`.
