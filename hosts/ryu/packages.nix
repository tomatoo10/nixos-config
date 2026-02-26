{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    sshfs
    OVMF
    blueman
    qemu
    virt-manager
    libvirt
    sbctl
  ];

  # virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true; # gui
  programs.xwayland.enable = true;
  programs.fish.enable = true;

  programs.hyprland.enable = true;
  # Testing KDE
  # services.xserver.enable = true; # optional
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm.settings.General.DisplayServer = "wayland";
  #
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   konsole
  #   elisa
  # ];

}
