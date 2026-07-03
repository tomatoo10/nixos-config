{...}: {
  services = {
    pihole-ftl = {
      enable = true;
      openFirewallDNS = true;
      openFirewallWebserver = true;
      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          description = "Pi-hole default blocklist";
        }
      ];
      settings = {
        dns.upstreams = [
          "1.1.1.1"
          "1.0.0.1"
        ];
        webserver.api.cli_pw = true;
      };
    };

    pihole-web = {
      enable = true;
      hostName = "pi.hole";
      ports = ["8081"];
    };
  };
}
