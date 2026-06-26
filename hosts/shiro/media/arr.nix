{...}: {
  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };
  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };
  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings.server.bindaddress = "*";
  };
  services.prowlarr = {
    enable = true;
    openFirewall = true;
    settings.server.bindaddress = "*";
  };
}
