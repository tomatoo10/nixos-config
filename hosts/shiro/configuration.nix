{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/ssh.nix
    ../../nixos/users.nix
    ../../nixos/docker.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModprobeConfig = ''
    # Keep Intel Wi-Fi awake for a server workload. The Realtek USB adapter is
    # currently disconnected, but this helps the active iwlwifi card.
    options iwlwifi power_save=0
  '';
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = config.var.hostname;
    useDHCP = false;
    wireless.enable = false;
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = false;
        };
        Settings.AutoConnect = true;
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
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
    nameservers = ["100.100.100.100" "1.1.1.1" "8.8.8.8"];
    search = ["taile3aadf.ts.net"];
  };

  time.timeZone = config.var.timeZone;

  i18n = {
    defaultLocale = config.var.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = config.var.extraLocale;
      LC_IDENTIFICATION = config.var.extraLocale;
      LC_MEASUREMENT = config.var.extraLocale;
      LC_MONETARY = config.var.extraLocale;
      LC_NAME = config.var.extraLocale;
      LC_NUMERIC = config.var.extraLocale;
      LC_PAPER = config.var.extraLocale;
      LC_TELEPHONE = config.var.extraLocale;
      LC_TIME = config.var.extraLocale;
    };
  };

  console.keyMap = config.var.keyboardLayout;

  services = {
    tailscale = {
      enable = true;
      extraSetFlags = ["--ssh=true" "--accept-dns=true"];
    };
    qbittorrent = {
      enable = true;
      group = "media";
      webuiPort = 8080;
      torrentingPort = 6881;
      openFirewall = true;
    };
    qui = {
      enable = true;
      openFirewall = true;
      settings = {
        host = "0.0.0.0";
        port = 7476;
      };
    };
    thermald.enable = true;
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = ["/"];
    };
  };

  users.groups.media = {};
  users.users."${config.var.username}".extraGroups = ["media"];

  systemd.tmpfiles.rules = let
    mediaDir = path: "d ${path} 2775 ${config.var.username} media - -";
    torrentDir = path: "d ${path} 2775 qbittorrent media - -";
  in
    (map mediaDir [
      "/srv/data"
      "/srv/data/media"
      "/srv/data/media/books"
      "/srv/data/media/anime"
      "/srv/data/media/movies"
      "/srv/data/media/music"
      "/srv/data/media/tv"
    ])
    ++ (map torrentDir [
      "/srv/data/torrents"
      "/srv/data/torrents/anime"
      "/srv/data/torrents/incomplete"
      "/srv/data/torrents/books"
      "/srv/data/torrents/movies"
      "/srv/data/torrents/music"
      "/srv/data/torrents/tv"
    ]);

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

  environment.systemPackages = with pkgs; [
    btop
    curl
    fastfetch
    git
    tailscale
    wget
  ];

  security.sudo.wheelNeedsPassword = false;

  documentation = {
    enable = true;
    doc.enable = false;
    dev.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  system.stateVersion = "26.05";
}
