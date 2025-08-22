{...}: {
  imports = [
    ./hyprland.nix
    ./waybar/waybar.nix
    ./alacritty.nix
  ];

  xdg.configFile."scripts" = {
    source = ./scripts;
    recursive = true;
  };
}
