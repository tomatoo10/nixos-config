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
    firewall = {
      enable = true;
      allowedTCPPorts = [22 11011];
      allowedUDPPorts = [6881];
      trustedInterfaces = ["tailscale0"];
    };
    interfaces.wlan0.ipv4.addresses = [
      {
        address = "192.168.18.7";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.18.1";
    nameservers = ["1.1.1.1" "8.8.8.8"];
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = ["--ssh=true" "--accept-dns=false"];
  };
}
