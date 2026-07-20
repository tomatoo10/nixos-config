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

## Post-install WebUI checklist

After first setup or restore, confirm these stateful WebUI settings:

- Radarr integration enabled, host `127.0.0.1`, port `7878`, SSL disabled.
- Sonarr integration enabled, host `127.0.0.1`, port `8989`, SSL disabled.
- Movie default subtitles enabled with the intended language profile.
- Series default subtitles enabled with the intended language profile.
- Wanted searches enabled for movies and series, currently every `6h`.
- Use scene name: enabled.
- Skip hashing: disabled, so hash matches can be used when providers support it.
- Parse embedded audio tracks: enabled, so Bazarr can make profile decisions
  from the real media audio languages.
- Use embedded subtitles: disabled, because the target is Plex-friendly sidecar
  SRT/ASS files and embedded ASS should not satisfy the wanted sidecar search.
- Ignore embedded PGS and VobSub subtitles: enabled, because bitmap subtitles
  are high-risk for Plex burn-in/transcoding and are not useful as search/sync
  satisfaction signals.
- Use custom post-processing: enabled with the Nix-owned subtitle guard command
  from the `Subtitle synchronization` section.
- Providers enabled and logged in where required. Provider credentials are
  stateful secrets and must not be committed.

## Subtitle strategy

Prefer sidecar SRT subtitles:

- Plex Web/mobile handle SRT far better than embedded VobSub/PGS bitmap subtitles.
- Embedded bitmap subtitles often force burn-in and video transcode.
- Sidecar SRT files should be written next to media files in the Radarr/Sonarr library folders.
- Sidecar ASS/SSA subtitles are acceptable, especially for anime, but they do
  not replace the need for SRT sidecars because Plex/client ASS support can be
  inconsistent.

Recommended language/profile baseline:

- English normal subtitles.
- Portuguese (Brazil) normal subtitles if wanted.
- Forced subtitles only if you explicitly want forced-only tracks.
- Hearing-impaired subtitles: optional; disable if you dislike SDH/HI text.
- Keep minimum scores findable rather than perfect: series around `90`, movies
  around `80`. Scores near `99` often prevent useful subtitles from being found.

## Automatic search settings

Keep automatic wanted searches enabled. Current observed useful settings are:

- Movie wanted search frequency: every 6 hours.
- Series wanted search frequency: every 6 hours.
- Movie minimum score: around `80`.
- Series minimum score: around `90`.
- Use scene name: enabled.
- Use embedded subtitles: disabled if the goal is Plex-friendly sidecars.

## Subtitle synchronization

Do not use Bazarr's built-in automatic subtitle synchronization for the anime
library. Dual-audio anime can put an English dub before the Japanese/original
audio track, and Bazarr/ffsubsync can then align Japanese-dialogue subtitles to
the dub and create subtitles that run far past the video duration.

Use the Nix-owned post-processing guard instead:

- Command: `/run/current-system/sw/bin/bazarr-subtitle-guard {{subtitles}} 2>&1`
- The guard infers the matching video from the sidecar filename.
- It validates that subtitle timing fits inside the video duration.
- If timing is impossible, it tries one conservative repair with ffsubsync using
  Japanese audio when present for SRT files.
- It only replaces the subtitle if the repaired result is sane and keeps at
  least 90% of the original cues.
- For ASS/SSA sidecars, it validates timing but does not auto-convert styled
  subtitles to SRT; impossible ASS/SSA is quarantined so Bazarr can search again.
- If repair is unsafe, it moves the bad sidecar to `.subtitle-guard-quarantine`
  so Plex will not use it and Bazarr can search again later.
- Originals are copied to `.subtitle-guard-backups` before repair/quarantine.

Recommended Bazarr settings for downloaded sidecars:

- Use subsync / automatic synchronization: disabled for series/anime.
- Custom post-processing: enabled with the command above.
- Parse embedded audio tracks: enabled.
- Use embedded subtitles: disabled.
- Ignore embedded PGS/VobSub: enabled.
- Ignore embedded ASS: disabled, so ASS remains visible to Bazarr/Plex metadata,
  but embedded ASS still does not satisfy wanted sidecar search because embedded
  subtitles are disabled globally.
- Movie automatic synchronization can stay enabled only if movie downloads are
  not showing the same wrong-reference behavior; otherwise use the guard there
  too.

The guard is intentionally conservative. It prevents clearly broken subtitles
from reaching Plex, but it does not try to "improve" every subtitle. A slightly
offset subtitle should be fixed by finding a better release match or by a manual
one-off repair, not by applying aggressive automatic sync to every download.

If these settings drift, Bazarr can download or create a high-scoring subtitle
that is still badly timed. This happened with `My Dress-Up Darling` when
automatic sync wrote sidecars whose final cues were several minutes past the
video duration.

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
- If subtitles are badly offset even with high Bazarr scores: check whether the
  subtitle had a hash match. If not, confirm subsync ran; low sync thresholds can
  skip high-scoring but wrong-timing subtitles.
- If no subtitles are found: check providers, language profile, minimum score, anti-captcha/provider limits, and whether the release name matches the provider result.
- If Plex still transcodes with SRT: inspect Plex playback info; Plex Web may still direct-stream audio/container even when video is copied.
