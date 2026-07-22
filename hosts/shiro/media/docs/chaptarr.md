# Chaptarr

Chaptarr is the active ebook/books manager experiment. It is alpha-ish and sparse on docs, so keep expectations conservative and prefer straightforward settings.

## Nix ownership

- Container: `hosts/shiro/media/containers.nix`
- Autostart: disabled until the Docker Hub image pull is verified on shiro.
- WebUI: `http://shiro:8789`
- LAN URL: `http://192.168.18.7:8789`
- Config: `/srv/chaptarr/config`
- Book library: `/srv/data/media/books`
- Torrent path: `/srv/data/torrents/books`

## Routing

- Use qBittorrent on `192.168.18.7:8080` from the container.
- Use qBittorrent category `books`.
- qBittorrent credentials and settings are stateful WebUI config, not Nix env vars, because upstream env support is not documented.

## Caveats

- Chaptarr is still immature compared with the established Arr stack.
- Pull/start manually during setup: `sudo podman pull docker.io/robertlordhood/chaptarr:latest`, then `sudo systemctl start podman-chaptarr.service`.
- Do not enable container autostart until the image is already present and a manual start has been tested. Previous rebuild/switch attempts blocked on shiro while Podman tried to pull ebook images during activation.
- Upstream docs are sparse; verify that `/config` persists during first live setup.
- Do not add public exposure.
- Do not commit credentials, API keys, or one-off WebUI state.

## Resource expectations

Chaptarr should not be a constant Plex bottleneck while idle, but searches,
imports, metadata work, and qBittorrent book downloads share shiro's same CPU,
RAM, network, and `/srv/data` disk. Keep it disabled unless actively testing the
books workflow, and avoid running heavy imports while Plex playback is active.

## Setup notes

Chaptarr handles acquisition and organization. Kavita serves the reading library.

If Chaptarr later grows stable native integrations, keep the host callbacks pointed at the shiro LAN IP unless the container is switched to host networking.
