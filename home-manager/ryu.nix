{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # Configs for ryu workspace
    ../modules/ryu
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Overlays
  nixpkgs.overlays = [
    inputs.alacritty-theme.overlays.default
  ];

  home = {
    username = "akame";
    homeDirectory = "/home/akame";
  };
  # Here lies packages that don't require any configuration/setup whatsoever.
  # Important apps are at ./modules/*
  home.packages = with pkgs; [
    # Fonts
    gohufont
    nerd-fonts.gohufont
    nerd-fonts.ubuntu-sans
    hachimarupop

    # Testing stuff
    evil-helix

    kitty # another terminal emulator if something goes wrong
    tree # display cool things
    fd # find stuff
    eza # print stuff

    wl-clipboard # wayland clipboard
    btop # process monitor
    fzf # fuzzy finder to find things
    ripgrep # finder to search for things
    bat # Replacing cat
    alejandra # nixformatter
    killall # utils (this shouldn't be here)
    ueberzugpp # Show images in terminal

    # Utils
    brave # browser
    pavucontrol # mixer
    playerctl # mixer ?
    spotify # Music yay
    duf # see disks

    # Screenshoot
    swappy
    grim
    slurp

    # Desktop
    hyprpaper # wallpaper
    hyprpicker # color picker
    hyprsunset # night filter
    greetd.regreet
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # cursor
    inputs.nixcats.packages.${pkgs.system}.default # nixcats
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}
