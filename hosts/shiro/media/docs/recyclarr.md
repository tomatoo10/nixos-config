# Recyclarr

## Nix ownership

- Module: `hosts/shiro/media/recyclarr.nix`
- Schedule: daily
- Radarr URL: `http://127.0.0.1:7878`
- Sonarr URL: `http://127.0.0.1:8989`
- Secrets:
  - `/var/lib/secrets/recyclarr-radarr-api-key`
  - `/var/lib/secrets/recyclarr-sonarr-api-key`

Recyclarr is the source of truth for quality profiles and custom formats. Manual profile/custom-format edits in Radarr/Sonarr can be overwritten.

## Managed Radarr profiles

- `Movies - 1080p Balanced` — TRaSH HD Bluray + WEB approximation of
  Profilarr/Dictionarry 1080p Balanced; smaller, practical 1080p movies.
- `Movies - 1080p Quality HDR` — manual Profilarr-inspired approximation for
  efficient 1080p HDR/x265 encodes without Remux sizing.
- `Movies - 1080p Remux Legacy` — preserved pre-existing 1080p Remux profile.
- `Movies - 2160p Balanced` — manual Profilarr-inspired practical 4K WEB/Bluray
  profile without Remux-first sizing.
- `Movies - 4K Test Legacy` — preserved pre-existing 4K test profile.
- `Movies - 2160p Quality` — TRaSH Remux + WEB 2160p quality-first profile.

The `Legacy` profiles keep the old behavior for existing/manual use. The new
Balanced profiles trade quality for smaller, more Plex-friendly files. The
Quality profiles are more aggressive and can consume more disk.

## Managed Sonarr profiles

- `Series - 1080p Balanced` — TRaSH WEB-1080p Alternative approximation of
  Profilarr/Dictionarry 1080p Balanced.
- `Series - 1080p Quality HDR` — manual Profilarr-inspired approximation for
  efficient 1080p HDR/x265 episodes without Remux as the cutoff.
- `Series - 1080p Remux Legacy` — preserved pre-existing 1080p Remux-like
  series profile.
- `Series - 2160p Balanced` — TRaSH WEB-2160p Alternative approximation of
  Profilarr/Dictionarry 2160p Balanced.
- `Series - 2160p Quality` — TRaSH WEB-2160p quality-first profile.
- `Anime - 1080p Remux Legacy` — preserved pre-existing TRaSH anime profile.

For normal TV, prefer `Series - 1080p Balanced` first. Use 2160p profiles only
for shows where 4K storage and playback cost are acceptable.

## Changing quality behavior

1. Edit `hosts/shiro/media/recyclarr.nix`.
2. Evaluate shiro.
3. Run `sudo systemctl start recyclarr.service` or wait for the timer.
4. Check `journalctl -u recyclarr --no-pager`.

Do not tune quality profiles directly in Radarr/Sonarr unless you immediately port the change back to Nix.
