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
      extraSetFlags = ["--ssh=true"];
    };
    qbittorrent = {
      enable = true;
      group = "media";
      webuiPort = 8080;
      torrentingPort = 6881;
      openFirewall = true;
    };
    radarr = {
      enable = true;
      group = "media";
      openFirewall = true;
      settings.server.bindaddress = "*";
    };
    sonarr = {
      enable = true;
      group = "media";
      openFirewall = true;
      settings.server.bindaddress = "*";
    };
    prowlarr = {
      enable = true;
      openFirewall = true;
      settings.server.bindaddress = "*";
    };
    plex = {
      enable = true;
      group = "media";
      openFirewall = true;
    };
    recyclarr = {
      enable = true;
      schedule = "daily";
      configuration = {
        radarr.radarr = {
          base_url = "http://127.0.0.1:7878";
          api_key._secret = "/var/lib/secrets/recyclarr-radarr-api-key";

          quality_definition.type = "movie";

          quality_profiles = [
            {
              trash_id = "9ca12ea80aa55ef916e3751f4b874151"; # Remux + WEB 1080p
              name = "Movies - 1080p Remux";
              reset_unmatched_scores.enabled = true;
              upgrade = {
                allowed = true;
                until_quality = "Remux-1080p";
                until_score = 10000;
              };
              min_format_score = -2000;
              quality_sort = "top";
              qualities = [
                {name = "Remux-1080p";}
                {name = "Bluray-1080p";}
                {
                  name = "WEB 1080p";
                  qualities = ["WEBDL-1080p" "WEBRip-1080p"];
                }
              ];
            }
            {
              trash_id = "64fb5f9858489bdac2af690e27c8f42f"; # UHD Bluray + WEB
              name = "Movies - 4K Test";
              reset_unmatched_scores.enabled = true;
              min_format_score = -2000;
            }
          ];

          custom_formats = [
            {
              trash_ids = [
                "570bc9ebecd92723d2d21500f4be314c" # Remaster
                "eecf3a857724171f968a66cb5719e152" # IMAX
                "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
              ];
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
            {
              trash_ids = [
                "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
              ];
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
            {
              trash_ids = [
                "ed38b889b31be83fda192888e2286d83" # BR-DISK
                "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
                "90a6f9a284dff5103f6346090e6280c8" # LQ
                "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                "0a3f082873eb454bde444150b70253cc" # Extras
                "712d74cd88bceb883ee32f773656b1f5" # Sing-Along Versions
                "cae4ca30163749b891686f95532519bd" # AV1
              ];
              score = -10000;
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
            {
              trash_ids = [
                "923b6abef9b17f937fab56cfcf89e1f1" # DV (w/o HDR fallback)
              ];
              score = -10000;
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
            {
              trash_ids = [
                "496f355514737f7d83bf7aa4d24f8169" # TrueHD Atmos
                "3cafb66171b47f226146a0770576870f" # TrueHD
                "2f22d89048b01681dde8afe203bf2e95" # DTS X
                "dcf3ec6938fa32445f590a4da84256cd" # DTS-HD MA
                "8e109e50e0a0b83a5098b056e13bf6db" # DTS-HD HRA
              ];
              score = -1500;
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
            {
              trash_ids = [
                "1c1a4c5e823891c75bc50380a6866f73" # DTS
                "a570d4a0e56a2874b64e5bfa55202a1b" # FLAC
                "e7c2fcae07cbada050a0af3357491d7b" # PCM
              ];
              score = -300;
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
            {
              trash_ids = [
                "1af239278386be2919e1bcee0bde047e" # DD+ Atmos
                "185f1dd7264c4562b9022d963ac37424" # DD+
                "c2998bd0d90ed5621d8df281e839436e" # DD
                "240770601cc226190c367ef59aba7463" # AAC
              ];
              score = 500;
              assign_scores_to = [
                {name = "Movies - 1080p Remux";}
                {name = "Movies - 4K Test";}
              ];
            }
          ];
        };

        sonarr.sonarr = {
          base_url = "http://127.0.0.1:8989";
          api_key._secret = "/var/lib/secrets/recyclarr-sonarr-api-key";

          quality_definition.type = "series";

          quality_profiles = [
            {
              trash_id = "72dae194fc92bf828f32cde7744e51a1"; # WEB-1080p
              name = "Series - 1080p Remux";
              upgrade = {
                allowed = true;
                until_quality = "Bluray-1080p Remux";
                until_score = 10000;
              };
              min_format_score = -2000;
              quality_sort = "top";
              qualities = [
                {name = "Bluray-1080p Remux";}
                {name = "Bluray-1080p";}
                {
                  name = "WEB 1080p";
                  qualities = ["WEBDL-1080p" "WEBRip-1080p"];
                }
                {name = "Bluray-720p";}
                {
                  name = "WEB 720p";
                  qualities = ["WEBDL-720p" "WEBRip-720p"];
                }
                {name = "HDTV-1080p";}
                {name = "HDTV-720p";}
              ];
            }
            {
              trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
              name = "Anime - 1080p Remux";
              reset_unmatched_scores.enabled = true;
            }
          ];

          custom_formats = [
            {
              trash_ids = [
                "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
              ];
              score = -10000;
              assign_scores_to = [
                {name = "Series - 1080p Remux";}
                {name = "Anime - 1080p Remux";}
              ];
            }
            {
              trash_ids = [
                "0d7824bb924701997f874e7ff7d4844a" # TrueHD Atmos
                "1808e4b9cee74e064dfae3f1db99dbfe" # TrueHD
                "9d00418ba386a083fbf4d58235fc37ef" # DTS X
                "c429417a57ea8c41d57e6990a8b0033f" # DTS-HD MA
                "cfa5fbd8f02a86fc55d8d223d06a5e1f" # DTS-HD HRA
              ];
              score = -1500;
              assign_scores_to = [
                {name = "Series - 1080p Remux";}
              ];
            }
            {
              trash_ids = [
                "5964f2a8b3be407d083498e4459d05d0" # DTS
                "30f70576671ca933adbdcfc736a69718" # PCM
              ];
              score = -300;
              assign_scores_to = [
                {name = "Series - 1080p Remux";}
              ];
            }
            {
              trash_ids = [
                "4232a509ce60c4e208d13825b7c06264" # DD+ Atmos
                "63487786a8b01b7f20dd2bc90dd4a477" # DD+
                "dbe00161b08a25ac6154c55f95e6318d" # DD
                "a50b8a0c62274a7c38b09a9619ba9d86" # AAC
              ];
              score = 500;
              assign_scores_to = [
                {name = "Series - 1080p Remux";}
              ];
            }
          ];
        };
      };
    };
    qui = {
      enable = true;
      openFirewall = true;
      secretFile = "/var/lib/secrets/qui-session.txt";
      settings = {
        host = "0.0.0.0";
        port = 7476;
        authDisabled = true;
        I_ACKNOWLEDGE_THIS_IS_A_BAD_IDEA = true;
        authDisabledAllowedCIDRs = [
          "192.168.18.0/24"
          "100.64.0.0/10"
        ];
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

  virtualisation.oci-containers.containers.cleanuparr = {
    image = "ghcr.io/cleanuparr/cleanuparr:latest";
    ports = ["11011:11011"];
    volumes = [
      "/srv/cleanuparr/config:/config"
      "/srv/data/torrents:/downloads"
    ];
    environment = {
      PORT = "11011";
      PUID = "1000";
      PGID = "1000";
      TZ = config.var.timeZone;
      UMASK = "002";
    };
  };

  systemd.tmpfiles.rules = let
    mediaDir = path: "d ${path} 2775 ${config.var.username} media - -";
    torrentDir = path: "d ${path} 2775 qbittorrent media - -";
  in
    [
      "d /var/lib/secrets 0700 root root - -"
    ]
    ++ (map mediaDir [
      "/srv/data"
      "/srv/data/media"
      "/srv/data/media/books"
      "/srv/data/media/anime"
      "/srv/data/media/movies"
      "/srv/data/media/music"
      "/srv/data/media/tv"
      "/srv/cleanuparr"
      "/srv/cleanuparr/config"
    ])
    ++ (map torrentDir [
      "/srv/data/torrents"
      "/srv/data/torrents/animes"
      "/srv/data/torrents/incomplete"
      "/srv/data/torrents/books"
      "/srv/data/torrents/movies"
      "/srv/data/torrents/music"
      "/srv/data/torrents/tv"
      "/srv/data/torrents/unlinked"
    ]);

  systemd.services.recyclarr = {
    after = ["network-online.target" "radarr.service" "sonarr.service"];
    wants = ["network-online.target" "radarr.service" "sonarr.service"];
    serviceConfig = {
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
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
