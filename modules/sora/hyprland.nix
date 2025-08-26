{
  pkgs,
  lib,
  ...
}: let
  walls = ../../wallpapers;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = ["--all"];
    };

    settings = {
      env = [
        "HYPRCURSOR_THEME, rose-pine-hyprcursor"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "GDK_BACKEND,wayland,x11,*"
        "NIXOS_OZONE_WL,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "MOZ_ENABLE_WAYLAND,1"
        "OZONE_PLATFORM,wayland"
        "EGL_PLATFORM,wayland"
        "CLUTTER_BACKEND,wayland"
        "SDL_VIDEODRIVER,wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "WLR_RENDERER_ALLOW_SOFTWARE,1"
        "NIXPKGS_ALLOW_UNFREE,1"
      ];

      exec-once = [
        "${lib.getExe pkgs.hyprpaper}"
        "${lib.getExe pkgs.waybar}"
      ];

      input = {
        kb_layout = "us,br";
        kb_variant = ",thinkpad";
        kb_options = "grp:alt_shift_toggle, caps:swapescape";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

       animations = {
        enabled = false;
        };

      general = {
        gaps_in = 4;
        gaps_out = 9;
        border_size = 2;
        # "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
        # "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
        resize_on_border = true;
        layout = "dwindle"; # dwindle or master
      };

      decoration = {
        shadow.enabled = false;
        dim_special = 0.3;
      };

      layerrule = [
        "ignorezero, rofi"
        "ignorealpha 0.7, rofi"
        "ignorezero, swaync-control-center"
        "ignorezero, swaync-notification-window"
        "ignorealpha 0.7, swaync-control-center"
      ];

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      misc = {
        disable_hyprland_logo = true;
        mouse_move_focuses_monitor = true;
        # swallow_regex = "^(Alacritty)$";
        # should be used in terminals so don't swallow it plz
        # swallow_exception_regex = "class:^ueberzugpp_";
        # enable_swallow = true;
        vfr = true; # always keep on
        vrr = 1; # enable variable refresh rate (0=off, 1=on, 2=fullscreen only)
      };

      xwayland.force_zero_scaling = false;

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
        new_on_top = true;
        mfact = 0.5;
      };

      windowrule = [
        # Move applications to different workspaces
        "suppressevent maximize, class: *"
        # "workspace 0, class:^(Spotify)$"
        # "workspace 0, title:(.*)(Spotify)(.*)$"
      ];

      binde = [
        # Functional keybinds
        ",XF86MonBrightnessDown,exec,brightnessctl set 2%-"
        ",XF86MonBrightnessUp,exec,brightnessctl set +2%"
        ",XF86AudioLowerVolume,exec,pamixer -d 2"
        ",XF86AudioRaiseVolume,exec,pamixer -i 2"
      ];

      "$mainMod" = "SUPER";
      "$term" = "alacritty";
      "$editor" = "nvim";
      "$fileManager" = "$term --class \"terminalFileManager\" -e yazi";
      "$browser" = "brave";

      bind =
        [
          # Night Mode (lower value means warmer temp)
          "$mainMod, F9, exec, ${lib.getExe pkgs.hyprsunset} --temperature 3500" # good values: 3500, 3000, 250
          "$mainMod, F10, exec, pkill hyprsunset"

          # Window/Session actions
          "$mainMod, Q, killactive" # killactive, kill the window on focus
          "$mainMod, delete, exit" # kill hyperland session
          "$mainMod SHIFT, SPACE, togglefloating" # toggle the window on focus to float
          "$mainMod SHIFT, G, togglegroup" # toggle the window on focus to float
          "$mainMod, T, togglesplit" # Toggle split
          "$mainMod, F, fullscreen" # toggle the window on focus to fullscreen

          # Applications/Programs
          "$mainMod, Return, exec, $term"
          "$mainMod SHIFT, Return, exec, [float;] $term"
          "$mainMod, E, exec, $fileManager"
          "$mainMod SHIFT, F, exec, $browser"
          "$mainMod, D, exec, rofi -no-lazy-grab -show drun" # launch desktop applications

          # Resize mode
          "$mainMod, R, submap, resize"
          "$mainMod, a, togglespecialworkspace"
          "$mainMod SHIFT, a, movetoworkspace, special"

          # Functional keybinds
          ",xf86Sleep, exec, systemctl suspend" # Put computer into sleep mode
          ",XF86AudioMicMute,exec,pamixer --default-source -t" # mute mic
          ",XF86AudioMute,exec,pamixer -t" # mute audio
          ",XF86AudioPlay,exec,playerctl play-pause" # Play/Pause media
          ",XF86AudioPause,exec,playerctl play-pause" # Play/Pause media
          ",xf86AudioNext,exec,playerctl next" # go to next media
          ",xf86AudioPrev,exec,playerctl previous" # go to previous media

          # Utils
          "$mainMod, S, exec, ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" - | ${lib.getExe' pkgs.wl-clipboard "wl-copy"} --type image/png"
          "$mainMod SHIFT, S, exec, ${lib.getExe pkgs.grim} -g \"$(${lib.getExe pkgs.slurp})\" \"/home/akame/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png\" && hyprctl notify 2 5000 \"rgb(a6e3a1)\" \"Screenshot Saved\""
          "$mainMod, C, exec, ${lib.getExe pkgs.hyprpicker} | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"

          # Alt tab with last
          "ALT, Tab, focuscurrentorlast"

          # Change focus to floating window
          "$mainMod, Tab, cyclenext"
          "$mainMod, Tab, bringactivetotop"

          # move to the first empty workspace instantly with mainMod + CTRL + [↓]
          "$mainMod CTRL, down, workspace, empty"

          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Move focus with mainMod + HJKL keys
          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          # Move window with mainMod + arrow keys
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"

          # Move focus with mainMod + HJKL keys
          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"

          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ]
        ++ (builtins.concatLists (builtins.genList (x: let
            ws = let
              c = (x + 1) / 10;
            in
              builtins.toString (x + 1 - (c * 10));
          in [
            # Go to workspace
            "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
            # Move window and go to workspace
            "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
            # Only move window
            "$mainMod CTRL, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
          ])
          10));

      bindm = [
        # Move/Resize windows with mainMod + LMB/RMB and dragging
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };

    extraConfig = ''
      # Easily plug in any monitor
      monitor=,preferred,auto,1

      submap = resize

      # Binds within the submap: use arrow keys to resize window
      # 'binde' makes the keybind repeat when held down
      binde=, l, resizeactive, 10 0
      binde=, h, resizeactive, -10 0
      binde=, k, resizeactive, 0 -10
      binde=, j, resizeactive, 0 10

      # Use escape to exit the submap
      bind=, escape, submap, reset

      # End the submap definition
      submap = reset
    '';
  };

  # Hyprpaper
  xdg.configFile."hypr/hyprpaper.conf" = {
    text = ''
      preload = ${walls}/light_anm07.png
      preload = ${walls}/dark_anm08.png
      preload = ${walls}/light_anm04.jpg
      preload = ${walls}/robot_light_girl.png
      preload = ${walls}/lucy-red-background.png
      preload = ${walls}/red.jpg
      wallpaper = , ${walls}/red.jpg
    '';
  };
}
