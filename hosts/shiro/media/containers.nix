{config, ...}: {
  virtualisation.oci-containers.containers = {
    cleanuparr = {
      image = "ghcr.io/cleanuparr/cleanuparr:latest";
      ports = ["11011:11011"];
      volumes = ["/srv/cleanuparr/config:/config" "/srv/data/torrents:/downloads"];
      environment = {
        PORT = "11011";
        PUID = "1000";
        PGID = "1000";
        TZ = config.var.timeZone;
        UMASK = "002";
      };
    };
    byparr = {
      image = "ghcr.io/thephaseless/byparr:latest";
      ports = ["127.0.0.1:8191:8191"];
      environment.TZ = config.var.timeZone;
    };
  };
}
