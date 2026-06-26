{...}: {
  services.plex = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
}
