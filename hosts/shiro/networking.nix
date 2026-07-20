# shiro networking pins the server to LAN IPv4 192.168.18.7 on the MAC-matched USB Wi-Fi adapter, keeps router DNS as the host resolver, opens only base firewall ports here, and leaves service-specific ports to service modules/WebUI docs.
{config, ...}: {
  systemd.network.links."10-shiro-lan" = {
    matchConfig.MACAddress = "00:e0:4d:0b:47:8d";
    linkConfig.Name = "shiro-lan";
  };

  networking = {
    hostName = config.var.hostname;
    useDHCP = false;
    wireless.enable = false;
    wireless.iwd = {
      enable = true;
      settings = {
        General.EnableNetworkConfiguration = false;
        Settings.AutoConnect = true;
      };
    };
    # Static LAN addresses stay on the known-good USB Wi-Fi adapter rather than
    # depending on kernel-assigned wlanX ordering.
    interfaces."shiro-lan".ipv4.addresses = [
      {
        address = "192.168.18.7";
        prefixLength = 24;
      }
    ];
    interfaces."shiro-lan".ipv6.addresses = [
      {
        address = "fd7a:c324:7131::7";
        prefixLength = 64;
      }
    ];
    defaultGateway = {
      address = "192.168.18.1";
      interface = "shiro-lan";
    };
    nameservers = ["192.168.18.1"];

    # Base firewall ports stay narrow; service modules open their own ports when needed.
    firewall = {
      enable = true;
      allowedTCPPorts = [22 11011 6868];
      allowedUDPPorts = [6881];
      trustedInterfaces = ["tailscale0"];
    };
  };

  services.tailscale = {
    enable = true;
    # shiro should not become a Tailscale DNS client; Pi-hole/router DNS is the
    # home-network source of truth.
    extraSetFlags = ["--ssh=true" "--accept-dns=false"];
  };
}
