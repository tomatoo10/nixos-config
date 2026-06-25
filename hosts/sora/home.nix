{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Programs
    ../../home/programs/brave
    ../../home/programs/alacritty
    ../../home/programs/ghostty
    ../../home/programs/nvf
    ../../home/programs/shell
    ../../home/programs/ssh
    ../../home/programs/git
    ../../home/programs/git/lazygit.nix
    ../../home/programs/git/signing.nix # Change the key or remove this file
    ../../home/programs/thunar
    ../../home/programs/nixy
    ../../home/programs/nightshift
    ../../home/programs/tools/cybersecurity.nix
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
      swappy # Screenshot tool
      openvpn

      # Dev
      docker
      python3
      uv
      jq
      cargo
      rustc
      clang
      nh

      # Gaming
      protonplus # GUI manager for Proton-GE and other compatibility tools
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
    monitor = ["eDP-1, 1920x1080@60, 0x0, 1"];
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
      # The touchpad device can exist and buttons can work while cursor motion
      # is suppressed in Hyprland/libinput. Avoid getting stuck in that state.
      disable_while_typing = false;
      scroll_factor = 0.4;
    };
  };

  programs.home-manager.enable = true;
  programs.man.enable = false;
}
