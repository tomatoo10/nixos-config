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

- `Movies - 1080p Remux`
- `Movies - 4K Test`

The 1080p profile prefers Remux/Bluray/WEB 1080p and rejects obvious low-quality or incompatible releases. Heavy lossless audio formats are penalized rather than fully blocked so good releases can still be selected when needed.

## Managed Sonarr profiles

- `Series - 1080p Remux`
- `Anime - 1080p Remux`

The series profile prefers 1080p Remux/Bluray/WEB with fallback to 720p/HDTV tiers. The anime profile follows the TRaSH anime profile baseline.

## Changing quality behavior

1. Edit `hosts/shiro/media/recyclarr.nix`.
2. Evaluate shiro.
3. Run `sudo systemctl start recyclarr.service` or wait for the timer.
4. Check `journalctl -u recyclarr --no-pager`.

Do not tune quality profiles directly in Radarr/Sonarr unless you immediately port the change back to Nix.
