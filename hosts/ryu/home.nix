{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Programs
    ../../home/programs/brave
    ../../home/programs/ghostty
    ../../home/programs/nvf
    ../../home/programs/shell
    ../../home/programs/fetch
    ../../home/programs/git
    ../../home/programs/git/lazygit.nix
    ../../home/programs/git/signing.nix # Change the key or remove this file
    ../../home/programs/spicetify
    ../../home/programs/thunar
    ../../home/programs/discord
    ../../home/programs/nixy
    ../../home/programs/zathura
    ../../home/programs/nightshift
    ../../home/programs/group/cybersecurity.nix
    ../../home/programs/nix-utils

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/caelestia-shell
    ../../home/system/hyprpaper
    ../../home/system/mime
    ../../home/system/udiskie

    ./variables.nix # Mostly user-specific configuration
    # ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    packages = with pkgs; [
      # Apps
      vlc # Video player
      blanket # White-noise app
      obsidian # Note taking app
      textpieces # Manipulate texts
      resources # Ressource monitor
      gnome-clocks # Clocks app
      gnome-text-editor # Basic graphic text editor
      mpv # Video player
      ticktick # Todo app
      session-desktop # Session app, private messages
      signal-desktop # Signal app, private messages
      stirling-pdf # PDF Editor
      calibre # Ebooks
      swappy # Screenshot tool
      pinta # Image editor
      notesnook
      element-desktop
      clamtk
      gh

      # Dev
      go
      bun
      docker
      nodejs
      python3
      uv
      jq
      just
      air
      duckdb
      lazydocker
      cargo
      rustc
      clang
      nh

      # Just cool
      peaclock
      cbonsai
      pipes
      cmatrix
      fastfetch
    ];

    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    # Import a profile picture, used by the caelestia dashboard
    file.".face" = {
      source = ./profile_picture.png;
    };

    sessionVariables = {
      AQ_DRM_DEVICES = "/dev/dri/card1";
    };

    # Don't touch this
    stateVersion = "24.05";
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, 1920x1080@144, 768x0, 1" # starts at logical width of rotated AOC
      "HDMI-A-1, 1360x768@60, 0x0, 1, transform, 3"
      ", preferred, auto, 1"
    ];
    workspace = [
      "1, monitor:DP-1, default:true"
      "2, monitor:DP-1"
      "3, monitor:DP-1"
      "4, monitor:DP-1"
      "5, monitor:DP-1"
      "6, monitor:DP-1"
      "7, monitor:DP-1"
      "8, monitor:DP-1"
      "9, monitor:DP-1"
      "10, monitor:HDMI-A-1, default:true"
      "11, monitor:HDMI-A-1"
      "12, monitor:HDMI-A-1"
    ];
    cursor.default_monitor = "DP-1";
  };

  programs.home-manager.enable = true;
}
