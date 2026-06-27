{
  config,
  lib,
  ...
}: {
  imports = [
    # Shared modules (same as sora, plus docker)
    ../../modules/core/home-manager.nix
    ../../modules/core/nix.nix # Flakes, caches, and garbage collection
    ../../modules/core/openssh.nix
    ../../modules/core/users.nix
    ../../modules/boot/secure-boot.nix # Lanzaboote secure boot using /var/lib/sbctl
    ../../modules/desktop/audio.nix # PipeWire audio stack
    ../../modules/desktop/display-manager.nix # SDDM login screen
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/hyprland.nix # Hyprland compositor from flake input
    ../../modules/desktop/workstation-base.nix # Desktop services, portals, packages, locale
    ../../modules/hardware/amd-gpu.nix # RADV Vulkan, VA-API, ROCm OpenCL
    ../../modules/virtualisation/docker.nix # Docker + user added to docker group

    # Hardware — ryu is a desktop, no TLP/thinkfan/battery needed
    ./hardware-configuration.nix # amd_pstate=active (works on ryu's Zen 3+), btrfs subvolumes
    ./variables.nix # Theme (gruvbox-dark-medium), user, locale
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Allow edit of /etc/hosts bc of HTB machines
  environment.etc.hosts.enable = lib.mkForce false;
  environment.etc.hosts.mode = lib.mkForce "0700";
  # NOTE: firewall disabled for HTB — consider re-enabling and opening only needed ports
  networking.firewall.enable = false;

  # Tailscale mesh VPN
  services.tailscale = {
    enable = true;
    extraSetFlags = ["--ssh=true" "--accept-dns=true"];
  };
  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Don't touch this
  system.stateVersion = "24.05";
}
