# Overseerr and Cloudflare Tunnel

This is a disabled scaffold for a future public request portal. Do not enable it
until you are ready to expose Overseerr through Cloudflare and test the login
flow.

- Module: `hosts/shiro/media/public-requests.nix`
- Enable flag: `shiro.media.publicRequests.enable`
- Planned local Overseerr URL: `http://localhost:5055`
- Public exposure: Cloudflare Tunnel to Overseerr only
- Tunnel token env file when enabled: `/var/lib/secrets/cloudflared-overseerr.env`

## Current status

The module is imported but disabled by default. Do not enable it until the public
Cloudflare hostname, Access/WAF policy, Plex login settings, and testing plan are
ready.

When enabled, users will visit a public Cloudflare hostname, log in with Plex,
and request media through Overseerr. The tunnel must point only to Overseerr on
`http://localhost:5055`.

## Security model

Only Overseerr should be public. Keep these private to LAN/Tailscale:

- Plex
- Radarr/Sonarr/Bazarr/Prowlarr
- qBittorrent
- Pi-hole
- Cleanuparr

Overseerr should use Plex login only. Configure the Plex integration inside the
Overseerr WebUI after first activation; that state is app-owned.

## Cloudflare-side policy

Country allow/block rules belong in Cloudflare WAF or Access, not in this repo,
unless Cloudflare is later managed declaratively. Planned controls:

- allow only intended countries or block all others
- enable Cloudflare Access if desired for an extra login layer
- add rate limiting/bot protections if the endpoint is abused

## Activation checklist

1. In Cloudflare Zero Trust, create a tunnel for the future Overseerr hostname.
2. Copy the tunnel token and create `/var/lib/secrets/cloudflared-overseerr.env` on `shiro`:

   ```text
   TUNNEL_TOKEN=...
   ```

3. Set `shiro.media.publicRequests.enable = true`.
4. Rebuild `shiro`.
5. Open Overseerr locally first and configure Plex login/libraries.
6. Create the Cloudflare Tunnel public hostname to `http://localhost:5055`.
7. Add Cloudflare Access/WAF country rules.
8. Verify only Overseerr is reachable publicly.

## WebUI setup after enabling

In Overseerr:

1. Sign in with the Plex admin account.
2. Connect to Plex at the private shiro address, not a public Plex URL.
3. Select the Plex libraries users may request into.
4. Add Radarr at `http://localhost:7878` or `http://192.168.18.7:7878`.
5. Add Sonarr at `http://localhost:8989` or `http://192.168.18.7:8989`.
6. Pick the default Radarr/Sonarr profiles and root folders.
7. Disable local/non-Plex login methods if the UI exposes that option.

Then make one test request and confirm it appears in Radarr/Sonarr.
