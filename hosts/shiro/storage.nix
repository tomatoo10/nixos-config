{
  config,
  pkgs,
  ...
}: {
  systemd.tmpfiles.rules = let
    mediaDir = path: "d ${path} 2775 ${config.var.username} media - -";
    torrentDir = path: "d ${path} 2775 qbittorrent media - -";
  in [
    "d /var/lib/secrets 0700 root root - -"
    "d /srv/data 2775 root media - -"
    (mediaDir "/srv/data/media")
    (mediaDir "/srv/data/media/books")
    (mediaDir "/srv/data/media/anime")
    (mediaDir "/srv/data/media/movies")
    (mediaDir "/srv/data/media/music")
    (mediaDir "/srv/data/media/tv")
    (mediaDir "/srv/cleanuparr")
    (mediaDir "/srv/cleanuparr/config")
    (torrentDir "/srv/data/torrents")
    (torrentDir "/srv/data/torrents/animes")
    (torrentDir "/srv/data/torrents/incomplete")
    (torrentDir "/srv/data/torrents/books")
    (torrentDir "/srv/data/torrents/movies")
    (torrentDir "/srv/data/torrents/music")
    (torrentDir "/srv/data/torrents/tv")
    (torrentDir "/srv/data/torrents/unlinked")
  ];

  services.fstrim.enable = true;
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  systemd.services.btrfs-balance-shiro = {
    description = "Light Btrfs balance for shiro";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      ${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=75 -musage=75 /
    '';
  };

  systemd.timers.btrfs-balance-shiro = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "6h";
    };
  };
}
