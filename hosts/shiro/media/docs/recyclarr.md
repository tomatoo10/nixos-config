# Recyclarr

## Status

Recyclarr is removed from the active NixOS configuration. There is no current
`hosts/shiro/media/recyclarr.nix` module, timer, or API-key secret requirement.
Profilarr is the active profile-management path now.

Profilarr is available at `http://shiro:6868` with config at
`/srv/profilarr/config`. Do not re-add Recyclarr to manage the same
profile/custom-format set while Profilarr owns it.

## Previously managed Radarr profiles

- `Movies - Legacy 1080p Remux + WEB` — preserved pre-existing 1080p
  Remux-first profile with Bluray and WEB fallbacks.
- `Movies - Legacy 2160p UHD Bluray + WEB` — preserved pre-existing 4K UHD
  Bluray + WEB test profile.

## Previously managed Sonarr profiles

- `Series - Legacy 1080p Remux + WEB` — preserved pre-existing 1080p series
  profile with Remux, Bluray, WEB, and HDTV fallbacks.

- `Anime - Legacy 1080p Remux` — preserved pre-existing TRaSH anime Remux
  profile.

Use Profilarr-managed profiles for active profile management unless intentionally
re-adding Recyclarr and confirming ownership does not overlap.

## Changing quality behavior

1. Recreate a `hosts/shiro/media/recyclarr.nix` module.
2. Add it to `hosts/shiro/configuration.nix` imports.
3. Evaluate shiro.
4. Apply the rebuild.
5. Run `sudo systemctl start recyclarr.service` or wait for the timer.
6. Check `journalctl -u recyclarr --no-pager`.

Do not tune quality profiles directly in Radarr/Sonarr unless you immediately port the change back to Nix.
