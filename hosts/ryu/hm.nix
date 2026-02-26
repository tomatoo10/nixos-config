{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # Configs for ryu workspace
    ../../modules/ryu
    ../../modules/common
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "ak4m3";
    homeDirectory = "/home/ak4m3";
  };

  # Here lies packages that don't require any configuration/setup whatsoever.
  # Important apps are at ./modules/*
  home.packages = with pkgs; [
    # Fonts
    gohufont
    nerd-fonts.gohufont
    nerd-fonts.ubuntu-sans
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    hachimarupop

    lazygit
    git
    libsForQt5.kolourpaint

    # Testing stuff
    evil-helix
    swaynotificationcenter

    kitty # another terminal emulator if something goes wrong
    tree # display cool things
    fd # find stuff
    eza # print stuff

    wl-clipboard # wayland clipboard
    localsend # Airdrop like
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
    hwloc

    obsidian
    claude-code

    # Screenshoot
    swappy
    grim
    slurp
    vlc

    # Desktop
    hyprpicker # color picker
    hyprsunset # night filter
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # cursor
    inputs.nixcats.packages.${pkgs.system}.default # nixcats
  ];

  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.command-not-found.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}
