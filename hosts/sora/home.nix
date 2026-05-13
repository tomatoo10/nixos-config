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
    ../../home/programs/thunar
    ../../home/programs/nixy
    ../../home/programs/zathura
    ../../home/programs/nightshift
    ../../home/programs/group/cybersecurity.nix
    ../../home/programs/mangohud

    # System (Desktop environment like stuff)
    ../../home/system/hyprland
    ../../home/system/caelestia-shell
    ../../home/system/hyprpaper
    ../../home/system/mime
    ../../home/system/udiskie

    ./variables.nix # Mostly user-specific configuration
  ];

  home = {
    packages = with pkgs; [
      # Apps
      vlc # Video player
      obsidian # Note taking app
      textpieces # Manipulate texts
      resources # Ressource monitor
      gnome-clocks # Clocks app
      session-desktop # Session app, private messages
      signal-desktop # Signal app, private messages
      stirling-pdf # PDF Editor
      swappy # Screenshot tool
      pinta # Image editor
      notesnook
      element-desktop
      clamtk
      openvpn

      # Dev
      docker
      python3
      uv
      jq
      just
      cargo
      rustc
      clang
      nh

      # Gaming
      protonplus # GUI manager for Proton-GE and other compatibility tools

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
    # file.".face" = {
    #   source = ./profile_picture.png;
    # };

    sessionVariables = {
      AQ_DRM_DEVICES = "/dev/dri/card1";
    };

    # Don't touch this
    stateVersion = "24.05";
  };

  wayland.windowManager.hyprland.settings = {
    monitor = ["eDP-1, 1920x1080@60.05, 0x0, 1"];
    workspace = [
      "1, monitor:eDP-1, default:true"
      "2, monitor:eDP-1"
      "3, monitor:eDP-1"
      "4, monitor:eDP-1"
      "5, monitor:eDP-1"
      "6, monitor:eDP-1"
      "7, monitor:eDP-1"
      "8, monitor:eDP-1"
      "9, monitor:eDP-1"
      "10, monitor:eDP-1"
    ];
    cursor.default_monitor = "eDP-1";
    input.touchpad = {
      natural_scroll = true;
      clickfinger_behavior = true;
      disable_while_typing = true;
      scroll_factor = 0.4;
    };
  };

  programs.home-manager.enable = true;
}
