# Auxiliary shiro containers run Profilarr, Cleanuparr, Byparr, Chaptarr, and Kavita via Podman-backed OCI; this file owns container wiring while each app's database/rules remain stateful under its documented config path.
{config, ...}: {
  virtualisation.oci-containers.containers = {
    chaptarr = {
      autoStart = false;
      image = "robertlordhood/chaptarr:latest";
      ports = ["8789:8789"];
      # Chaptarr upstream docs are sparse; /config is the persistent state mount to verify during first live setup, and /srv/data gives the app access to book torrent/library paths.
      volumes = ["/srv/chaptarr/config:/config" "/srv/data:/srv/data"];
      environment = {
        TZ = config.var.timeZone;
      };
    };

    profilarr = {
      image = "ghcr.io/dictionarry-hub/profilarr:latest";
      ports = ["6868:6868"];
      volumes = ["/srv/profilarr/config:/config"];
      environment.TZ = config.var.timeZone;
    };

    kavita = {
      autoStart = false;
      image = "jvmilazz0/kavita:latest";
      ports = ["5000:5000"];
      volumes = ["/srv/kavita/config:/kavita/config" "/srv/data/media/books:/books"];
      # The jvmilazz0 image documents TZ and uses host mount permissions.
      environment = {
        TZ = config.var.timeZone;
      };
    };

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
