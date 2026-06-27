# Plex

## Nix ownership

- Module: `hosts/shiro/media/plex.nix`
- WebUI: `http://shiro:32400/web`
- State: `/var/lib/plex/Plex Media Server`

Plex account claim, libraries, metadata, clients, and most server preferences are stateful.

## Libraries

Create libraries with these folders:

- Movies: `/srv/data/media/movies`
- TV Shows: `/srv/data/media/tv`
- Anime: `/srv/data/media/anime`

Do not point Plex libraries at `/srv/data/torrents` or qBittorrent category folders.

Do not create Plex libraries from the `unlinked` qBittorrent category. That path
is temporary cleanup staging for old public torrent payloads and may be deleted
by Cleanuparr.

## Network settings

Recommended Plex preferences:

- Custom access URLs: `http://192.168.18.7:32400,http://100.110.91.84:32400`
- Allowed networks: `192.168.18.0/24,10.88.0.0/16,100.64.0.0/10`
- Publish server on Plex Online: enabled

LAN clients should prefer `192.168.18.7`. Tailscale clients may use `100.110.91.84` or MagicDNS.

If a client can reach the WebUI through one URL but does not show the server in
the app, check Custom access URLs before changing firewall or Tailscale settings.
Both LAN and Tailscale URLs should be present so clients choose a direct route
instead of falling back to relay/remote discovery.

If an iPhone on the same LAN with Tailscale enabled cannot see libraries:

1. Confirm iOS Local Network permission is enabled for Plex.
2. Confirm the Plex app account is the same account/home that owns the server.
3. Confirm the custom access URLs include both LAN and Tailscale URLs.
4. Try `http://192.168.18.7:32400/web` and `http://100.110.91.84:32400/web` from the phone browser.
5. Sign out/in or reset the Plex app if browser access works but the app is stale.

## Subtitles and transcoding

Prefer SRT sidecar subtitles from Bazarr. Embedded VobSub/PGS image subtitles often force subtitle burn-in and video transcode, especially in Plex Web.

Plex Web may still use Direct Stream instead of Direct Play if the browser cannot direct-play the container/audio combination. That is acceptable when video is copied and only audio/subtitle streams are converted.

For best direct-play compatibility:

- Prefer H.264/H.265 video supported by the client.
- Prefer AAC/AC3/EAC3 audio for browsers/mobile.
- Prefer SRT sidecars.
- Avoid selecting embedded bitmap subtitles in Plex Web.

## Restore notes

The lightweight backup includes `Preferences.xml` and Plex databases, not the full metadata cache/thumbnails. Restoring metadata images may require Plex to refresh metadata.
