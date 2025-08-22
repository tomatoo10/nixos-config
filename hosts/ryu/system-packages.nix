{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git

    # virtualization
    qemu
    virt-manager
    libvirt

    # secureboot
    sbctl
  ];

  # virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true; # gui

  # fish config is manager responsible but shell is installed systemwide
  # programs.fish.enable = true;
  programs.git.enable = true;
  programs.command-not-found.enable = true;
  programs.fish.enable = true;

  # this would be pulled by nixpkgs
  # programs.hyprland.enable = true;
  # this below, instead, will be pulled by the inputs variable set in flake.nix and imported bc of specialargs = {inherint inputs };
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # enable the xwayland compatibility layer for x11 applications
  programs.xwayland.enable = true;
}
