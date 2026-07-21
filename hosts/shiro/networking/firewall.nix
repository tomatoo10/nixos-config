# shiro networking centralizes private service firewall exposure so wildcard-bound
# admin UIs do not become public just because the host has a global IPv6 address.
{pkgs, ...}: let
  lanIPv4 = "192.168.18.0/24";
  lanULA = "fd7a:c324:7131::/64";
  tailscaleIPv4 = "100.64.0.0/10";
  tailscaleIPv6 = "fd7a:115c:a1e0::/48";
  podmanIPv4 = "10.88.0.0/16";

  # Private service/admin ports. These are available from the home LAN ULA/IPv4,
  # Tailscale, and the Podman bridge where container callbacks require them, but
  # are not opened to arbitrary global IPv6 sources.
  privateTCPPorts = "22,53,3005,6767,6868,7878,8080,8081,8324,8989,9696,11011,32400,32469";
  privateUDPPorts = "53,1900,5353,32410,32412,32413,32414";
in {
  # Keep qBittorrent's peer port globally reachable for torrent connectivity.
  # All admin/service ports are opened by source-restricted rules below instead
  # of per-service `openFirewall = true`, which would also expose them on any
  # global IPv6 address assigned to shiro-lan.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [6881];
    allowedUDPPorts = [6881];
    trustedInterfaces = [];
    extraCommands = ''
      ${pkgs.iptables}/bin/iptables -A nixos-fw -i shiro-lan -s ${lanIPv4} -p tcp -m multiport --dports ${privateTCPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/iptables -A nixos-fw -i shiro-lan -s ${lanIPv4} -p udp -m multiport --dports ${privateUDPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/iptables -A nixos-fw -i tailscale0 -s ${tailscaleIPv4} -p tcp -m multiport --dports ${privateTCPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/iptables -A nixos-fw -i tailscale0 -s ${tailscaleIPv4} -p udp -m multiport --dports ${privateUDPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/iptables -A nixos-fw -i podman0 -s ${podmanIPv4} -p tcp -m multiport --dports ${privateTCPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/iptables -A nixos-fw -i podman0 -s ${podmanIPv4} -p udp -m multiport --dports ${privateUDPPorts} -j nixos-fw-accept

      ${pkgs.iptables}/bin/ip6tables -A nixos-fw -i shiro-lan -s ${lanULA} -p tcp -m multiport --dports ${privateTCPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/ip6tables -A nixos-fw -i shiro-lan -s ${lanULA} -p udp -m multiport --dports ${privateUDPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/ip6tables -A nixos-fw -i tailscale0 -s ${tailscaleIPv6} -p tcp -m multiport --dports ${privateTCPPorts} -j nixos-fw-accept
      ${pkgs.iptables}/bin/ip6tables -A nixos-fw -i tailscale0 -s ${tailscaleIPv6} -p udp -m multiport --dports ${privateUDPPorts} -j nixos-fw-accept
    '';
  };
}
