{...}: {
  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true;
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

  systemd.services = {
    # Radarr/Sonarr create media directories and Bazarr writes sidecar subtitle
    # files into them. Keep new files group-writable for the shared `media`
    # group instead of leaving them owner-only via the default 0022 umask.
    radarr.serviceConfig.UMask = "0002";
    sonarr.serviceConfig.UMask = "0002";
    bazarr.serviceConfig.UMask = "0002";
  };
}
