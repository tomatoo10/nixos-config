{
  inputs,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    blueman
    zerotierone
  ];

  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.xwayland.enable = true;
}
