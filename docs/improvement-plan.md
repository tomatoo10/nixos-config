# NixOS configuration improvement plan

This file tracks approved and still-open improvement ideas for `ryu`, `sora`, and
`shiro`. Only items marked **approved** should be implemented without another
confirmation.

## Implemented in Git

- Enable the firewall on `sora` while keeping Steam and existing service port
  openings intact.
- Require a sudo password on all hosts except the existing `sora` `power-mode`
  helper and the narrow `nixos-rebuild` exception.
- Remove the Docker CLI package from `sora` because the Docker daemon is not
  enabled there.
- Remove Qui and Recyclarr Nix service modules. Keep their docs as removed-service
  notes explaining why they were removed and how to re-add them later.
- Disable Brave secure DNS/DoH so browser DNS goes through the system resolver and
  Pi-hole. Remove stale Brave manual TODO notes.
- Set `nixpkgs.config.allowBroken = false` and add narrow exceptions only if a
  needed package actually requires one later.
- Disable Tailscale DNS acceptance on `ryu` and `sora` so DHCP-provided DNS wins.
  At home, DHCP advertises Pi-hole directly as `192.168.18.7`; away from home,
  the active network provides DNS unless a deliberate conditional/Tailscale DNS
  design is added later.

## Runtime follow-up after rebuild

- Confirm `ryu` and `sora` use DHCP-provided DNS after rebuild.
- Confirm home-network default lookups for `radarr.home` reach Pi-hole and return
  `192.168.18.7`.

## Decided no-op

- shiro backups: no full automated backup service for now. Media content is
  disposable, and only service SQL/config state is backed up manually when needed.
- qBittorrent LAN/Tailscale auth bypass remains accepted for the current trusted
  network model.
- Tailscale remains a trusted interface because only trusted devices are allowed in
  the tailnet.

## Still under consideration

- Monitoring/alerts for shiro. Possible direction: a small Rust health-check
  program plus systemd timer, or existing tools if they fit cleanly.
- `sops-nix` for deploy-time secrets such as future Cloudflare Tunnel tokens.
- Hyprland systemd integration test on `ryu`.
- Container image pinning for Profilarr, Cleanuparr, and Byparr.
- Removing unused flake inputs and empty/TODO modules.

## Monitoring/alerts rough plan

1. Decide notification target: ntfy, email, Healthchecks.io, or a small custom
   service.
2. Check disk usage, SMART health, Btrfs scrub result, failed systemd units, and
   core service health.
3. Run checks from a systemd timer.
4. Send one concise alert per failure category.
5. Keep this lightweight unless a full monitoring stack becomes worthwhile.

## `sops-nix` rough plan

1. Enable the `sops-nix` flake input and module.
2. Generate age keys for hosts that need secrets.
3. Add `.sops.yaml` and encrypted host secret files.
4. Start with future Cloudflare Tunnel token delivery.
5. Do not move app databases, Pi-hole passwords, or WebUI-owned state into sops.
