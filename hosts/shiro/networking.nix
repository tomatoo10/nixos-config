# shiro networking pins the server to LAN IPv4 192.168.18.7, keeps router DNS as the host resolver, opens only base firewall ports here, and leaves service-specific ports to service modules/WebUI docs.
{config, ...}: {
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
    # Static LAN IPv4 and router DNS keep shiro on the home network while Pi-hole/router handoff is in progress.
    interfaces.wlan0.ipv4.addresses = [
      {
        address = "192.168.18.7";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.18.1";
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
    # shiro should not become a Tailscale DNS client; ryu/sora handle that instead.
    extraSetFlags = ["--ssh=true" "--accept-dns=false"];
  };
}
