{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Browsers
    ../../home/browsers/brave

    # Terminals
    ../../home/terminals/alacritty
    ../../home/terminals/ghostty

    # Editors
    ../../home/editors/nvf

    # CLI
    ../../home/cli/shell
    ../../home/cli/ssh
    ../../home/cli/git
    ../../home/cli/git/lazygit.nix
    ../../home/cli/git/signing.nix # Change the key or remove this file
    ../../home/cli/tools/ai-memory.nix
    ../../home/cli/tools/cybersecurity.nix

    # Desktop
    ../../home/desktop/hyprland
    ../../home/desktop/caelestia-shell
    ../../home/desktop/hyprpaper
    ../../home/desktop/mime
    ../../home/desktop/udiskie

    # Programs
    ../../home/programs/spicetify
    ../../home/programs/thunar
    ../../home/programs/nightshift

    # Host-specific
    ./variables.nix # Mostly user-specific configuration
  ];
  home = {
    packages = with pkgs; [
      # Apps
      vlc # Video player
      obsidian # Note taking app
      swappy # Screenshot tool
      gh
      localsend

      # Dev
      go
      docker
      nodejs
      python3
      uv
      jq
      just
      lazydocker
      cargo
      rustc
      clang
      nh
      # Test
      google-chrome
      firefox
    ];

    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    # Import a profile picture, used by the caelestia dashboard
    file.".face" = {
      source = ./profile_picture.jpeg;
      force = true;
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
  programs.man.enable = false;
}
