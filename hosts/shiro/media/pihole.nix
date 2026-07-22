# Pi-hole runs natively as shiro's LAN DNS/ad-blocking service; this file owns upstreams, base blocklist, local DNS names, and limits while password/query DB stay local state.
{...}: {
  services = {
    # Native Pi-hole owns DNS/ad-blocking on shiro; the old container setup is no longer the source of truth.
    pihole-ftl = {
      enable = true;
      # Firewall exposure is centralized in hosts/shiro/networking so DNS and
      # WebUI access stay limited to LAN/Tailscale/Podman sources for both IPv4
      # and IPv6.
      openFirewallDNS = false;
      openFirewallWebserver = false;
      settings = {
        # Keep plain Cloudflare upstreams for now; encrypted upstream DNS can be added later via Stubby if needed.
        dns.upstreams = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        # Local service names are owned in Nix so they survive Pi-hole rebuilds
        # and do not depend on manual WebUI state. Ports are still required.
        dns.hosts = [
          "192.168.18.7 home.server"
        ];
        # The home LAN can create short DNS bursts from browsers, Tailscale, and
        # Nix substituters. Raise Pi-hole's defaults modestly without disabling
        # protection against runaway clients.
        dns.rateLimit = {
          count = 3000;
          interval = 60;
        };
        misc.dnsmasq_lines = [
          "dns-forward-max=300"
        ];
        # Allow CLI password changes to update the WebUI-owned password state.
        webserver.api.cli_pw = true;
      };
    };

    pihole-web = {
      enable = true;
      hostName = "pi.hole";
      # Expose the WebUI on 8081 to match the documented LAN access path.
      ports = ["8081"];
    };
  };
}
