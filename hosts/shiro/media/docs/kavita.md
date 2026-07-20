# Kavita

## Ownership

- Nix module wiring: `hosts/shiro/media/containers.nix`
- WebUI: `http://shiro:5000`
- LAN URL: `http://192.168.18.7:5000`
- Config: `/srv/kavita/config`
- Library: `/srv/data/media/books`

Kavita is stateful for accounts, libraries, and reading progress. Keep those WebUI-owned settings out of Git.

## Notes

- LAN/Tailscale only; do not expose publicly.
- Do not store secrets or API keys in Git.
