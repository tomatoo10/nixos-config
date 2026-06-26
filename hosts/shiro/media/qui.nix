{...}: {
  services.qui = {
    enable = true;
    openFirewall = true;
    secretFile = "/var/lib/secrets/qui-session.txt";
    settings = {
      host = "0.0.0.0";
      port = 7476;
      authDisabled = true;
      I_ACKNOWLEDGE_THIS_IS_A_BAD_IDEA = true;
      authDisabledAllowedCIDRs = ["192.168.18.0/24" "100.64.0.0/10"];
    };
  };
}
