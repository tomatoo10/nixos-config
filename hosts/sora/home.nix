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

  programs.home-manager.enable = true;
}
