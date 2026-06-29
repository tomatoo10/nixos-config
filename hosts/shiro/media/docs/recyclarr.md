# Recyclarr

## Nix ownership

- Module: `hosts/shiro/media/recyclarr.nix`
- Schedule: daily
- Radarr URL: `http://127.0.0.1:7878`
- Sonarr URL: `http://127.0.0.1:8989`
- Secrets:
  - `/var/lib/secrets/recyclarr-radarr-api-key`
  - `/var/lib/secrets/recyclarr-sonarr-api-key`

Recyclarr is currently disabled while Profilarr is being tested. If re-enabled,
it owns only the legacy quality profiles and shared custom-format scores below.
Manual edits to those Radarr/Sonarr profiles can be overwritten.

Profilarr is available on shiro only as a test service at `http://shiro:6868` with config at `/srv/profilarr/config`. Do not let Profilarr manage the same profiles or custom formats as Recyclarr; the two will conflict, and Recyclarr-owned settings will win back on the next sync.

## Managed Radarr profiles

- `Movies - Legacy 1080p Remux + WEB` — preserved pre-existing 1080p
  Remux-first profile with Bluray and WEB fallbacks.
- `Movies - Legacy 2160p UHD Bluray + WEB` — preserved pre-existing 4K UHD
  Bluray + WEB test profile.

The `Legacy` profiles keep the old behavior for existing/manual use while
Profilarr is evaluated separately.

## Managed Sonarr profiles

- `Series - Legacy 1080p Remux + WEB` — preserved pre-existing 1080p series
  profile with Remux, Bluray, WEB, and HDTV fallbacks.
- `Anime - Legacy 1080p Remux` — preserved pre-existing TRaSH anime Remux
  profile.

For normal TV, use Profilarr-managed profiles unless intentionally selecting one
of these legacy Recyclarr profiles.

## Changing quality behavior

1. Edit `hosts/shiro/media/recyclarr.nix`.
2. Evaluate shiro.
3. Run `sudo systemctl start recyclarr.service` or wait for the timer.
4. Check `journalctl -u recyclarr --no-pager`.

Do not tune quality profiles directly in Radarr/Sonarr unless you immediately port the change back to Nix.
