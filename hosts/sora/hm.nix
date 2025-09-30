{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # Configuration of applications used by sora workspace.
    ../../modules/sora
    ../../modules/common
  ];

  # Here lies packages that don't require any configuration/setup whatsoever.
  # Important apps are at ./modules/*
  home.packages = with pkgs; [
    # Fonts
    gohufont
    nerd-fonts.gohufont
    nerd-fonts.ubuntu-sans
    nerd-fonts.jetbrains-mono
    hachimarupop # Cute japanese font

    # Testing stuff
    evil-helix # This is a editor
    swaynotificationcenter # This create notifications

    kitty # another terminal emulator if something goes wrong
    tree # display cool things
    fd # find stuff
    eza # print stuff

    lazygit
    git

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
    inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default # cursor
    inputs.nixcats.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.command-not-found.enable = true;
  programs.ssh.extraConfig = ''
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
  '';

  home = {
    username = "ak4m3";
    homeDirectory = "/home/ak4m3";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}
