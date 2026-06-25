This directory is reserved for `shiro` secrets.

Do not copy old encrypted secrets from the upstream template or old server here.
Create new secrets for this host with `sops-nix` after the age recipients are
defined in the repository root `.sops.yaml`.

Expected future secrets may include:

- Wi-Fi credentials, if we stop using the local iwd profile file.
- Tailscale auth key, if we move from browser login to declarative auth.
- Cloudflare tunnel token, if public access is enabled.
- ARR/Recyclarr/qBittorrent/Plex API keys or service credentials.
