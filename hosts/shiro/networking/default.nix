{config, ...}: {
  imports = [./firewall.nix];

  # OpenSSH is enabled by a shared core module, but shiro's SSH exposure is owned
  # by the source-restricted firewall rules in this file instead of the service's
  # global `openFirewall` default.
  services.openssh.openFirewall = false;

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
    # depending on kernel-assigned wlanX ordering. The router advertises the ULA
    # prefix and has IPv6 forwarding firewalling enabled, but shiro still keeps a
    # host firewall policy below so private admin ports are protected even if
    # router policy changes later.
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
  };

  services.tailscale = {
    enable = true;
    # shiro should not become a Tailscale DNS client; Pi-hole/router DNS is the
    # home-network source of truth.
    extraSetFlags = ["--ssh=true" "--accept-dns=false"];
  };
}
