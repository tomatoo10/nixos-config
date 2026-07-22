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
- Do not enable container autostart until the image is already present and a manual start has been tested. Previous rebuild/switch attempts blocked on shiro while Podman tried to pull ebook images during activation.
- Do not store secrets or API keys in Git.

## Resource expectations

Kavita should be low-impact while idle, but first library scans, metadata
generation, and archive parsing can create CPU, memory, and disk IO bursts on
the same old laptop hardware that serves Plex. Keep it disabled unless actively
testing the books library, and schedule large scans away from Plex playback.
