# Pi-hole on shiro

Pi-hole runs as native NixOS services managed by `services.pihole-ftl` and `services.pihole-web`.

- WebUI: `http://shiro:8081/admin`
- DNS endpoint: `192.168.18.7:53`
- State: `/var/lib/pihole`
- Config: `/etc/pihole`
- Upstream DNS: Cloudflare (`1.1.1.1`, `1.0.0.1`)
- Blocklist: Pi-hole default StevenBlack hosts list

## Password setup

After first deploy, set the WebUI password on `shiro`:

```bash
sudo pihole setpassword
```

Do not commit Pi-hole passwords or password hashes to Git.

## DNS fallback

Pi-hole uses Cloudflare upstreams:

```text
1.1.1.1
1.0.0.1
```

Do not add the router (`192.168.18.1`) as a fallback upstream unless its DNS behavior is confirmed. If the router forwards DNS back to Pi-hole after DHCP is changed, using the router as an upstream can create a DNS loop.

## Deployment checks

After switching the system, verify the native service and DNS before changing router DHCP:

```bash
systemctl status pihole-FTL --no-pager
dig @192.168.18.7 example.com
```

Then open `http://shiro:8081/admin` from a LAN client.

## Router DHCP setup

Once direct DNS tests work, set the router DHCP DNS server to:

```text
192.168.18.7
```

Prefer handing `192.168.18.7` directly to clients instead of making clients use the router as a DNS forwarder. Direct client DNS lets Pi-hole show per-device query logs.

The NixOS hosts are configured to use the router (`192.168.18.1`) for DNS. After router DHCP points clients at Pi-hole, verify that the router itself does not forward Pi-hole's upstream queries back to Pi-hole.

## Tailscale

Do not enable Tailscale DNS forwarding until LAN Pi-hole has been stable for a few days. If enabled later, use `shiro`'s Tailscale IP as a nameserver in the Tailscale admin console and test one client first.

## Local DNS records

Pi-hole can provide local names, but DNS does not include ports. These records are still useful:

```text
shiro.home       -> 192.168.18.7
radarr.home      -> 192.168.18.7
sonarr.home      -> 192.168.18.7
prowlarr.home    -> 192.168.18.7
bazarr.home      -> 192.168.18.7
qbittorrent.home -> 192.168.18.7
plex.home        -> 192.168.18.7
pihole.home      -> 192.168.18.7
```

Without a reverse proxy, service URLs still need ports, for example `http://radarr.home:7878`.

## Blocklists

Start with the default Pi-hole lists. Add aggressive blocklists slowly because they can break smart TVs, auth flows, indexers, or media apps.
