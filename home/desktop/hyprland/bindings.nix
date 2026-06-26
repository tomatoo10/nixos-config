{
  pkgs,
  lib,
  config,
  ...
}: let
  colors = config.lib.stylix.colors;

  mkMenu = menu: let
    configFile =
      pkgs.writeText "config.yaml"
      (lib.generators.toYAML {} {
        anchor = "bottom-right";
        border = "#${colors.base0D}80";
        background = "#${colors.base01}EE";
        color = "#${colors.base05}";
        margin_right = 15;
        margin_bottom = 15;
        rows_per_column = 5;

        inherit menu;
      });
  in
    pkgs.writeShellScriptBin "menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';
in {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$shiftMod" = "SUPER_SHIFT";

    bindd =
      [
        # Applications
        ("$shiftMod, A, Application Menu, exec, "
          + lib.getExe (mkMenu [
            {
              key = "a";
              desc = "Proton Authenticator";
              cmd = "env WEBKIT_DISABLE_COMPOSITING_MODE=1 ${pkgs.proton-authenticator}/bin/proton-authenticator";
            }
            {
              key = "v";
              desc = "Proton VPN";
              cmd = "${pkgs.proton-vpn}/bin/protonvpn-app";
            }
            {
              key = "o";
              desc = "Obsidian";
              cmd = "${pkgs.obsidian}/bin/obsidian";
            }

            # Changed to localsend
            {
              key = "s";
              desc = "LocalSend";
              cmd = "${pkgs.localsend}/bin/localsend_app";
            }
            {
              key = "b";
              desc = "Brave";
              cmd = "${pkgs.brave}/bin/brave";
            }
            {
              key = "i";
              desc = "Brave (Private window)";
              cmd = "${pkgs.brave}/bin/brave --incognito";
            }
          ]))

        # Web links
        "$mod, F, Browser (Brave), exec, uwsm app -- ${pkgs.brave}/bin/brave"
        ("$shiftMod, F, Web Shortcuts Menu, exec, "
          + lib.getExe (mkMenu [
            {
              key = "h";
              desc = "Home";
              cmd = "${pkgs.brave}/bin/brave 'https://akmee.xyz'";
            }
            {
              key = "m";
              desc = "Mail";
              cmd = "${pkgs.brave}/bin/brave 'https://mail.google.me/u/0/inbox'";
            }
            {
              key = "c";
              desc = "Claude";
              cmd = "${pkgs.brave}/bin/brave 'https://claude.ai/new'";
            }
            {
              key = "w";
              desc = "WhatsApp";
              cmd = "${pkgs.brave}/bin/brave 'https://web.whatsapp.com/'";
            }
            {
              key = "g";
              desc = "Github";
              cmd = "${pkgs.brave}/bin/brave 'https://github.com/'";
            }
            {
              key = "n";
              desc = "MyNixos";
              cmd = "${pkgs.brave}/bin/brave 'https://mynixos.com/'";
            }
          ]))

        # Power
        "$mod, X, Session Menu, global, caelestia:session"
        ("$shiftMod, X, Power Menu, exec, "
          + lib.getExe (mkMenu [
            {
              key = "l";
              desc = "Lock";
              cmd = "hyprctl dispatch global caelestia:lock";
            }
            {
              key = "s";
              desc = "Suspend";
              cmd = "systemctl suspend";
            }
            {
              key = "r";
              desc = "Reboot";
              cmd = "systemctl reboot";
            }
            {
              key = "p";
              desc = "Power Off";
              cmd = "systemctl poweroff";
            }
            {
              key = "n";
              desc = "Nightshift";
              cmd = "nightshift-toggle";
            }
            {
              key = "c";
              desc = "Restart caelestia";
              cmd = "hyprctl dispatch exec 'caelestia-shell kill | sleep 1 | caelestia-shell'";
            }
          ]))

        # Quick launch
        "$mod, RETURN, Ghostty (terminal), exec, uwsm app -- ${pkgs.ghostty}/bin/ghostty"
        "$shiftMod, Return, Floating Ghostty, exec, [float;] uwsm app -- ${pkgs.ghostty}/bin/ghostty"
        "$mod, E, Thunar, exec, uwsm app -- ${pkgs.thunar}/bin/thunar"
        "$shiftMod, E, Emoji picker, exec, pkill fuzzel || caelestia emoji -p"
        "$mod, D, Launcher, global, caelestia:launcher"
        "$shiftMod, D, Dashboard, exec, caelestia shell drawers toggle dashboard"
        "$mod, N, Sidebar (Notifications), exec, caelestia shell drawers toggle sidebar"

        # Windows
        "$mod, Q, Close window, killactive"
        "$mod, SPACE, Toggle fullscreen, fullscreen"
        "$shiftMod, SPACE, Toggle floating, togglefloating"

        # Focus Windows
        "$mod, H, Move focus left, movefocus, l"
        "$mod, J, Move focus Down, movefocus, d"
        "$mod, K, Move focus Up, movefocus, u"
        "$mod, L, Move focus Right, movefocus, r"

        # Move windows
        "$shiftMod, H, Move window left, movewindow, l"
        "$shiftMod, J, Move window down, movewindow, d"
        "$shiftMod, K, Move window up, movewindow, u"
        "$shiftMod, L, Move window right, movewindow, r"

        # Alt tab functionality
        "ALT, Tab, Focus last window, focuscurrentorlast"
        "$mod, Tab, Cycle next window, cyclenext"

        "$shiftMod, left, Focus previous monitor, focusmonitor, -1"
        "$shiftMod, right, Focus next monitor, focusmonitor, 1"

        "$shiftMod, T, Swap split, layoutmsg, swapsplit"
        "$mod, T, Toggle split, layoutmsg, togglesplit"

        # Utilities
        "$shiftMod, G, Toggle Focus/Game mode, exec, caelestia shell gameMode toggle"
        "$shiftMod, S, Capture region (freeze), global, caelestia:screenshotFreeze"
        ", Print, Capture region (freeze), global, caelestia:screenshotFreeze"
        "$shiftMod+Alt, S, Capture region, global, caelestia:screenshot"

        # Specific workspaces
        "$mod, 0, Switch to workspace 10, workspace, 10"
        "$mod SHIFT, 0, Move to workspace 10, movetoworkspace, 10"
        "$mod, minus, Switch to workspace 11, workspace, 11"
        "$mod SHIFT, minus, Move to workspace 11, movetoworkspace, 11"
        "$mod, equal, Switch to workspace 12, workspace, 12"
        "$mod SHIFT, equal, Move to workspace 12, movetoworkspace, 12"
      ]
      ++ (builtins.concatLists (builtins.genList (i: let
          ws = i + 1;
        in [
          "$mod, code:1${toString i}, Switch to workspace ${toString ws}, workspace, ${toString ws}"
          "$mod SHIFT, code:1${toString i}, Move to workspace ${toString ws}, movetoworkspace, ${toString ws}"
        ])
        9));

    bindm = [
      "$mod,mouse:272, movewindow" # Move Window (mouse)
      "$mod,R, resizewindow" # Resize Window (mouse)
    ];

    bindl = [
      # Brightness
      ", XF86MonBrightnessUp, global, caelestia:brightnessUp"
      ", XF86MonBrightnessDown, global, caelestia:brightnessDown"

      # Media
      ", XF86AudioPlay, global, caelestia:mediaToggle"
      ", XF86AudioPause, global, caelestia:mediaToggle"
      ", XF86AudioNext, global, caelestia:mediaNext"
      ", XF86AudioPrev, global, caelestia:mediaPrev"
      ", XF86AudioStop, global, caelestia:mediaStop"

      # Sound
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioRaiseVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ];

    bindin = [
      # Launcher
      "$mod, mouse:272, global, caelestia:launcherInterrupt"
      "$mod, mouse:273, global, caelestia:launcherInterrupt"
      "$mod, mouse:274, global, caelestia:launcherInterrupt"
      "$mod, mouse:275, global, caelestia:launcherInterrupt"
      "$mod, mouse:276, global, caelestia:launcherInterrupt"
      "$mod, mouse:277, global, caelestia:launcherInterrupt"
      "$mod, mouse_up, global, caelestia:launcherInterrupt"
      "$mod, mouse_down, global, caelestia:launcherInterrupt"
    ];
  };
}
