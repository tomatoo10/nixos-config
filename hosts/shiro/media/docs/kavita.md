# Kavita

## Ownership

- Nix module wiring: `hosts/shiro/media/containers.nix`
- Autostart: disabled until the Docker Hub image pull is verified on shiro.
- WebUI: `http://shiro:5000`
- LAN URL: `http://192.168.18.7:5000`
- Config: `/srv/kavita/config`
- Library: `/srv/data/media/books`

Kavita is stateful for accounts, libraries, and reading progress. Keep those WebUI-owned settings out of Git.

## Notes

- LAN/Tailscale only; do not expose publicly.
- Pull/start manually during setup: `sudo podman pull docker.io/jvmilazz0/kavita:latest`, then `sudo systemctl start podman-kavita.service`.
- Do not store secrets or API keys in Git.
