{
  config,
  lib,
  ...
}: {
  services = {
    recyclarr = {
      enable = false;
      schedule = "daily";
      configuration = {
        radarr.radarr = {
          base_url = "http://127.0.0.1:7878";
          api_key._secret = "/var/lib/secrets/recyclarr-radarr-api-key";

          quality_definition.type = "movie";

          quality_profiles = [
            {
              trash_id = "9ca12ea80aa55ef916e3751f4b874151"; # Remux + WEB 1080p
              name = "Movies - Legacy 1080p Remux + WEB";
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
              name = "Movies - Legacy 2160p UHD Bluray + WEB";
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
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
              ];
            }
            {
              trash_ids = [
                "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
              ];
              assign_scores_to = [
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
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
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
              ];
            }
            {
              trash_ids = [
                "923b6abef9b17f937fab56cfcf89e1f1" # DV (w/o HDR fallback)
              ];
              score = -10000;
              assign_scores_to = [
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
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
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
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
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
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
                {name = "Movies - Legacy 1080p Remux + WEB";}
                {name = "Movies - Legacy 2160p UHD Bluray + WEB";}
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
              name = "Series - Legacy 1080p Remux + WEB";
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
              name = "Anime - Legacy 1080p Remux";
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
                {name = "Series - Legacy 1080p Remux + WEB";}
                {name = "Anime - Legacy 1080p Remux";}
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
                {name = "Series - Legacy 1080p Remux + WEB";}
              ];
            }
            {
              trash_ids = [
                "5964f2a8b3be407d083498e4459d05d0" # DTS
                "30f70576671ca933adbdcfc736a69718" # PCM
              ];
              score = -300;
              assign_scores_to = [
                {name = "Series - Legacy 1080p Remux + WEB";}
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
                {name = "Series - Legacy 1080p Remux + WEB";}
              ];
            }
          ];
        };
      };
    };
  };

  # Recyclarr needs Radarr/Sonarr online before it can sync quality profiles and
  # custom formats. Secrets are local files, not committed API keys.
  systemd.services.recyclarr = lib.mkIf config.services.recyclarr.enable {
    after = ["network-online.target" "radarr.service" "sonarr.service"];
    wants = ["network-online.target" "radarr.service" "sonarr.service"];
    serviceConfig = {
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
  };
}
