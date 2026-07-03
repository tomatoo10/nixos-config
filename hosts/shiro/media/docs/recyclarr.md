# Recyclarr

## Nix ownership

- Module: `hosts/shiro/media/recyclarr.nix`
- Schedule: daily
- Radarr URL: `http://127.0.0.1:7878`
- Sonarr URL: `http://127.0.0.1:8989`
- Secrets:
  - `/var/lib/secrets/recyclarr-radarr-api-key`
  - `/var/lib/secrets/recyclarr-sonarr-api-key`

Recyclarr is disabled by default. The full legacy Radarr/Sonarr config is retained
in Git for reference or selective reuse, but Profilarr is the main
profile-management path now.

Profilarr is available at `http://shiro:6868` with config at
`/srv/profilarr/config`. Do not let Profilarr and Recyclarr manage the same
profile/custom-format set.

## Managed Radarr profiles

- `Movies - Legacy 1080p Remux + WEB` — preserved pre-existing 1080p
  Remux-first profile with Bluray and WEB fallbacks.
- `Movies - Legacy 2160p UHD Bluray + WEB` — preserved pre-existing 4K UHD
  Bluray + WEB test profile.

## Managed Sonarr profiles

- `Series - Legacy 1080p Remux + WEB` — preserved pre-existing 1080p series
  profile with Remux, Bluray, WEB, and HDTV fallbacks.

- `Anime - Legacy 1080p Remux` — preserved pre-existing TRaSH anime Remux
  profile.

Use Profilarr-managed profiles for active profile management unless intentionally
re-enabling one legacy Recyclarr profile and confirming ownership does not
overlap.

## Changing quality behavior

1. Edit `hosts/shiro/media/recyclarr.nix`.
2. Evaluate shiro.
3. Run `sudo systemctl start recyclarr.service` or wait for the timer.
4. Check `journalctl -u recyclarr --no-pager`.

Do not tune quality profiles directly in Radarr/Sonarr unless you immediately port the change back to Nix.
