# Profilarr

## Main profile-management experiment

- URL: `http://shiro:6868`
- Config path: `/srv/profilarr/config`
- Container image: `ghcr.io/dictionarry-hub/profilarr:latest`

Profilarr is deployed on shiro as the main profile-management experiment for Radarr/Sonarr. Recyclarr has been removed from the active configuration, so Profilarr state is the only profile-management path currently in use.

## First-time WebUI setup

Open `http://shiro:6868` from the LAN/Tailscale network.

In Profilarr:

1. Add Radarr:
   - URL: `http://192.168.18.7:7878` or `http://localhost:7878` if Profilarr supports same-host access from its container.
   - API key: copy from Radarr WebUI → Settings → General.
2. Add Sonarr:
   - URL: `http://192.168.18.7:8989` or `http://localhost:8989` if same-host access works.
   - API key: copy from Sonarr WebUI → Settings → General.
3. Configure Media Management for each Arr instance before profile sync:
   - Naming config.
   - Quality Definitions config.
   - Media Settings config.
   - Sync method, usually `on_pull` so a database pull also refreshes the Arr
     instance.
4. Import/select the profiles Profilarr should manage for movies and normal TV.
5. Apply/sync Media Management, Delay Profiles, then Quality Profiles.
6. In Radarr/Sonarr, confirm the expected profiles and quality definitions appear.

If container-to-host localhost does not work, use the LAN IP `192.168.18.7`.

## Ownership rule

Profilarr owns the active Radarr/Sonarr profile and media-management experiment,
including quality definitions. If Recyclarr is ever re-added, disable Profilarr
ownership for the same profiles/media-management settings before syncing
Recyclarr. Never let both tools sync the same profile or quality definitions at
the same time.

Safe order if switching ownership later:

1. Disable the old manager.
2. Rebuild/restart if needed.
3. Confirm the old manager did not run again.
4. Enable/sync the new manager.
5. Check Radarr/Sonarr profiles after sync.

## Quality definitions

Profilarr can and should own Radarr/Sonarr Quality Definitions for shiro. These
are hard Arr gates for release size (`minSize`, `maxSize`, `preferredSize`) and
run before custom-format scoring. If Sonarr rejects high-scoring anime releases
for minimum/maximum size, check Profilarr Media Management sync before manually
editing Sonarr.

July 2026 finding:

- Profilarr's selected Dictionarry `Sonarr` quality definitions were already
  permissive: `minSize = 0`, unlimited `maxSize`, `preferredSize = 990`.
- Live Sonarr was stale and still had strict minimums such as
  `Bluray-1080p = 50.4 MB/min`, causing efficient anime releases to be rejected
  before custom-format scoring.
- Cause: Sonarr's Profilarr Media Management sync was not being kept current.
- Fix: set Sonarr Media Management sync to `on_pull` and run Media Management
  sync from the Sonarr instance's Profilarr Sync page. The successful job is
  `arr.sync.mediaManagement` and should report `mediaManagement: 3 item(s)`;
  logs should include `Updating 22 quality definitions`.

Verification commands, without searches/grabs/deletes:

```bash
ssh shiro.lan
# Check Profilarr sync state in /srv/profilarr/config/data/profilarr.db.
# Check Sonarr/Radarr /api/v3/qualitydefinition through their API keys.
```

After a healthy Sonarr sync, anime-relevant 720p/1080p definitions should have
`minSize = 0`, `maxSize = null`, and `preferredSize = 990`.

## Backup and restore

Profilarr state lives in `/srv/profilarr/config`. Restore that directory from the
ignored backup, then restart `podman-profilarr.service`.
