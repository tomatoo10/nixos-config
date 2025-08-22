{...}: {
  imports = [
    ./hyprland.nix
    ./waybar/waybar.nix
  ];

  xdg.configFile."scripts" = {
    source = ./scripts;
    recursive = true;
  };
}
