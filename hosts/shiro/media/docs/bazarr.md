# Bazarr

## Nix ownership

- Module: `hosts/shiro/media/arr.nix`
- WebUI: `http://shiro:6767`
- State: `/var/lib/bazarr`
- Service group: `media`
- Service umask: `0002`

Bazarr's WebUI settings, language profiles, providers, history, and subtitles database are stateful.

## Required app links

Configure Bazarr to talk to the local Arr services:

- Radarr address: `http://localhost:7878`
- Sonarr address: `http://localhost:8989`

Use the matching API keys from each app's WebUI. Do not commit them.

## Subtitle strategy

Prefer sidecar SRT subtitles:

- Plex Web/mobile handle SRT far better than embedded VobSub/PGS bitmap subtitles.
- Embedded bitmap subtitles often force burn-in and video transcode.
- Sidecar SRT files should be written next to media files in the Radarr/Sonarr library folders.

Recommended language/profile baseline:

- English normal subtitles.
- Portuguese (Brazil) normal subtitles if wanted.
- Forced subtitles only if you explicitly want forced-only tracks.
- Hearing-impaired subtitles: optional; disable if you dislike SDH/HI text.

## Automatic search settings

Keep automatic wanted searches enabled. Current observed useful settings are:

- Movie wanted search frequency: every 6 hours.
- Series wanted search frequency: every 6 hours.
- Movie minimum score: around `80`.
- Series minimum score: around `90`.
- Use scene name: enabled.
- Use embedded subtitles: disabled if the goal is Plex-friendly sidecars.

If a subtitle has a high score but does not appear, check logs and write permissions before assuming score rules are wrong. Permission failures can look like search/scoring failures from the WebUI.

## Permissions

Library directories must be group-writable by `media`:

- Directories: `2775`
- Media/subtitle files: group-readable and preferably group-writable
- Radarr/Sonarr/Bazarr umask: `0002`

If Bazarr logs `PermissionError(13, 'Permission denied')`, fix ownership/modes on `/srv/data/media` rather than lowering security on Bazarr.

## Troubleshooting

- Logs: `/var/lib/bazarr/log/bazarr.log`
- Database: `/var/lib/bazarr/db/bazarr.db`
- If Bazarr finds subtitles but fails to save: check directory write permission for the `bazarr` user/group `media`.
- If no subtitles are found: check providers, language profile, minimum score, anti-captcha/provider limits, and whether the release name matches the provider result.
- If Plex still transcodes with SRT: inspect Plex playback info; Plex Web may still direct-stream audio/container even when video is copied.
