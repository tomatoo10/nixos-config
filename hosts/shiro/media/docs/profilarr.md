# Profilarr

## Test service only

- URL: `http://shiro:6868`
- Config path: `/srv/profilarr/config`
- Container image: `ghcr.io/dictionarry-hub/profilarr:latest`

Profilarr is deployed on shiro as a test service. Recyclarr remains the source of truth for Radarr/Sonarr quality profiles and custom formats.

Do not configure Profilarr to manage the same profiles/custom formats as Recyclarr. That will conflict with, or be overwritten by, Recyclarr-managed state.
