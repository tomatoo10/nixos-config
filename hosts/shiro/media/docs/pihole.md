# Pi-hole on shiro

Pi-hole runs as native NixOS services managed by `services.pihole-ftl` and `services.pihole-web`.

- WebUI: `http://192.168.18.7:8081/admin` (`http://shiro:8081/admin` only if DNS resolves it)
- DNS endpoint: `192.168.18.7:53`
- IPv6 DNS endpoint: `fd7a:c324:7131::7:53`
- State: `/var/lib/pihole`
- Config: `/etc/pihole`
- Upstream DNS: Cloudflare (`1.1.1.1`, `1.0.0.1`)
- Blocklists: stateful Pi-hole gravity/WebUI data. Do not manage default
  blocklists through `services.pihole-ftl.lists` because the generated setup
  unit re-adds them on every activation and can fail on existing databases.

## Password setup

After first deploy, set the WebUI password on `shiro`:

```bash
sudo pihole setpassword
```

Do not commit Pi-hole passwords, password hashes, or query databases to Git.

## DNS fallback

Pi-hole uses plain Cloudflare upstreams intentionally for now:

```text
1.1.1.1
1.0.0.1
```

Do not add the router (`192.168.18.1`) as a fallback upstream unless its DNS behavior is confirmed. If the router forwards DNS back to Pi-hole after DHCP is changed, using the router as an upstream can create a DNS loop.

Encrypted upstream DNS is still a future option; Stubby can be added later if/when it is worth the extra moving parts.

## Deployment checks

After switching the system, verify the native service and DNS before changing router DHCP/DNS:

```bash
systemctl status pihole-FTL --no-pager
dig @192.168.18.7 example.com
dig @fd7a:c324:7131::7 example.com
```

Then open `http://192.168.18.7:8081/admin` from a LAN client.

## Router DHCP setup

Once direct DNS tests work, set the router DHCP/RA DNS servers to:

```text
IPv4 DNS: 192.168.18.7
IPv6 DNS: fd7a:c324:7131::7
```

Prefer handing `192.168.18.7` directly to clients instead of making clients use the router as a DNS forwarder. Direct client DNS lets Pi-hole show per-device query logs and keeps blocking stricter.

If IPv6 DNS remains enabled on clients or the router, they can bypass Pi-hole unless IPv6 DNS is also controlled. Use shiro's stable ULA `fd7a:c324:7131::7`, not its temporary public/privacy IPv6 addresses.

Avoid adding ISP/router secondary DNS if strict blocking is the goal; clients may fall back around Pi-hole.

## Tailscale

Do not enable Tailscale DNS forwarding until LAN Pi-hole has been stable for a few days. If enabled later, use `shiro`'s Tailscale IP as a nameserver in the Tailscale admin console and test one client first.

## Local DNS records

Pi-hole local DNS records are Nix-owned in `hosts/shiro/media/pihole.nix`. DNS does not include ports, so service URLs still need ports:

```text
home.server -> 192.168.18.7
```

Without a reverse proxy, service URLs still need ports, for example `http://home.server:7878`.

## Blocklists

Blocklists are stateful Pi-hole gravity/WebUI data, not Nix-owned config. Do
not use `services.pihole-ftl.lists` for the default StevenBlack list: the NixOS
module currently generates a setup step that tries to add configured lists every
activation, which is not idempotent on an existing Pi-hole database and can make
`pihole-ftl-setup.service` fail while FTL itself keeps running.

Start with the default Pi-hole lists. Add aggressive blocklists slowly because they can break smart TVs, auth flows, indexers, or media apps.

## Post-DNS-change validation

After any Pi-hole or router DNS change, check:

- Prowlarr indexer tests
- qBittorrent tracker resolution
- Radarr and Sonarr search/grab flow
- Byparr proxying in Prowlarr
- Plex web/app sanity check for library reachability
