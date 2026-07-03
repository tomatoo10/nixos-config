# Profilarr

## Main profile-management experiment

- URL: `http://shiro:6868`
- Config path: `/srv/profilarr/config`
- Container image: `ghcr.io/dictionarry-hub/profilarr:latest`

Profilarr is deployed on shiro as the main profile-management experiment for Radarr/Sonarr. Recyclarr is disabled by default; its legacy Radarr/Sonarr config remains in Git but must not be enabled against profiles Profilarr owns.

Do not configure Profilarr to manage the same anime legacy profile/custom formats as Recyclarr if Recyclarr is re-enabled for that profile. Keep ownership split clearly.

## First-time WebUI setup

Open `http://shiro:6868` from the LAN/Tailscale network.

In Profilarr:

1. Add Radarr:
   - URL: `http://192.168.18.7:7878` or `http://localhost:7878` if Profilarr supports same-host access from its container.
   - API key: copy from Radarr WebUI → Settings → General.
2. Add Sonarr:
   - URL: `http://192.168.18.7:8989` or `http://localhost:8989` if same-host access works.
   - API key: copy from Sonarr WebUI → Settings → General.
3. Import/select the profiles Profilarr should manage for movies and normal TV.
4. Apply/sync the profiles.
5. In Radarr/Sonarr, confirm the expected profiles appear and are selected for new media.

If container-to-host localhost does not work, use the LAN IP `192.168.18.7`.

## Ownership rule

Profilarr owns the active Radarr/Sonarr profile experiment. Keep Recyclarr disabled
unless you are intentionally testing one legacy profile. Never let both tools sync
the same profile at the same time.

Safe order if switching ownership later:

1. Disable the old manager.
2. Rebuild/restart if needed.
3. Confirm the old manager did not run again.
4. Enable/sync the new manager.
5. Check Radarr/Sonarr profiles after sync.

## Backup and restore

Profilarr state lives in `/srv/profilarr/config`. Restore that directory from the
ignored backup, then restart `podman-profilarr.service`.
