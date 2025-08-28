{pkgs, ...}: let
  # minimal-brown, gruvbox
  theme = "gruvbox";
  pythonWithMyLibs = pkgs.python3.withPackages (ps:
    with ps; [
      pyquery
    ]);
in {
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./${theme}/style.css;
    settings = [
      {
        layer = "top"; # Waybar at top layer
        height = 24; # Waybar height (to be removed for auto height)
        spacing = 4; # Gaps between modules (4px)

        modules-left = [
          "hyprland/workspaces"
          "cava"
          "hyprland/submap" # Normal mode or resize mode TODO: NEED Tweaks
        ];

        modules-center = [
          "clock"
          "mpris"
        ];

        modules-right = [
          "cpu"
          "memory"
          "disk"
          "wireplumber" # Audio control
          # "custom/weather" # change to wttrbar
        ];

        disk = {
          format = "{percentage_used}% 󰋊";
        };

        "custom/weather" = {
          exec = "${pythonWithMyLibs}/bin/python3 ${./scripts/weather.py}";
          "restart-interval" = 300;
          "return-type" = "json";
          # "on-click" = "xdg-open https://weather.com/en-IN/weather/today/l/$(location_id)";
          # "format-alt" = "{alt}";
        };

        # Modules configuration
        "hyprland/workspaces" = {
          "all-outputs" = true;
          "warp-on-scroll" = false;
          "enable-bar-scroll" = true;
          "disable-scroll-wraparound" = true;
          format = "{icon}";

          "format-icons" = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
          };

          "persistent-workspaces" = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
            "5" = [];
            "6" = [];
            "7" = [];
            "8" = [];
            "9" = [];
            "10" = [];
          };
        };

        "hyprland/window" = {
          format = "{title}";
          "max-length" = 40;
          "all-outputs" = true;
        };

        cava = {
          framerate = 30;
          autosens = 1;
          bars = 14;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 10000;
          method = "pipewire";
          source = "auto";
          stereo = true;
          bar_delimiter = 0;
          noise_reduction = 0.77;
          input_delay = 2;
          hide_on_silence = true;
          "format-icons" = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          actions = {
            "on-click-right" = "mode";
          };
        };

        mpris = {
          format = "{status_icon} {dynamic}";
          interval = 1;
          "dynamic-len" = 40;
          "status-icons" = {
            paused = "▶";
            playing = "⏸";
            stopped = "";
          };
          "dynamic-order" = ["title" "artist"];
          "ignored-players" = ["brave" "firefox"];
        };

        cpu = {
          interval = 1;
          format = "{usage:>2}% {icon0} {icon1} {icon2} {icon3}";
          "format-icons" = [
            "<span color='#8ec07c'>▁</span>" # Aqua
            "<span color='#8ec07c'>▂</span>" # Aqua
            "<span color='#b8bb26'>▃</span>" # Green
            "<span color='#b8bb26'>▄</span>" # Green
            "<span color='#fabd2f'>▅</span>" # Yellow
            "<span color='#fabd2f'>▆</span>" # Yellow
            "<span color='#fe8019'>▇</span>" # Orange
            "<span color='#fb4934'>█</span>" # Red
          ];
        };

        clock = {
          timezone = "America/Sao_Paulo";
          format = "{:%H:%M 󰃭 %a, %d %b %Y}";
          "format-alt" = "{:%Y-%m-%d}";
        };

        memory = {
          format = "{used}% ";
        };

        wireplumber = {
          "scroll-step" = 5; # %, can be a float
          format = "{icon} {volume}%";
          "format-bluetooth" = "{icon} {volume}% ";
          "format-bluetooth-muted" = " {icon}";
          "format-muted" = "";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
      }
    ];
  };

  # Weather
  xdg.configFile."waybar/scripts/weather.py".source = ./scripts/weather.py;
}
