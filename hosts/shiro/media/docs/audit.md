# shiro media audit notes

Prioritized follow-ups from the architecture audit:

1. Plain Cloudflare DNS is the intentional steady state for now. Cloudflared/DoH can be revisited later as an optional feature, not a current requirement.
2. Router DNS behavior has been confirmed with IPv4-only Pi-hole and no secondary resolver. Keep watching for IPv6 DNS bypass if IPv6 is later re-enabled.
3. Pi-hole local DNS records are now declarative in `hosts/shiro/media/pihole.nix`; add new stable service names there instead of through the WebUI.
4. Consider a central firewall exposure inventory for shiro services.
5. Stale `hosts/shiro/media/firewall.nix` and `fail2ban.nix` modules were removed; recreate a focused module later only if public services need it.
6. Remove old live `/srv/pihole` and unused container residue after confirming no active service depends on it.
7. Qui is configured but disabled. Profilarr stays exposed on LAN/Tailscale because it is the main profile-management experiment.
8. Overseerr and Cloudflare Tunnel are scaffolded but disabled; finish Cloudflare Access/WAF and Plex login setup before enabling.
