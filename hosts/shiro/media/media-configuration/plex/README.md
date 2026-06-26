# Plex configuration

Plex stores server identity, tokens, libraries, metadata, and user/watch state in
its application state. Do not commit Plex databases or tokens.

Nix only declares the native Plex service, opens its firewall ports, and runs it
with access to the shared `media` group.

## WebUI

- **Local URL**: `http://localhost:32400/web`
- **LAN URL**: `http://192.168.18.7:32400/web`

## Libraries

Create these libraries in the Plex WebUI after a fresh install or restore them
from Plex state backup:

- **Movies**: `/srv/data/media/movies`
- **TV**: `/srv/data/media/tv`
- **Anime**: `/srv/data/media/anime`

Avoid pointing Plex at `/srv/data/torrents`; Plex should only scan final media
library folders.
