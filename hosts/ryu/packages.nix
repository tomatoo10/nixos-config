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
  programs.hyprland.enable = true;
  programs.virt-manager.enable = true; # gui
  programs.xwayland.enable = true;
  programs.fish.enable = true;
}
