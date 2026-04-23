{
  config,
  lib,
  ...
}: {
  imports = [
    # Shared modules (same as sora, plus docker)
    ../../nixos/audio.nix # PipeWire audio stack
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix # Flakes, cachix substituters, garbage collection
    ../../nixos/lanzaboote.nix # Secure Boot via lanzaboote (needs /var/lib/sbctl enrolled)
    ../../nixos/sddm.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix # NetworkManager, power-profiles-daemon (desktop uses this, sora overrides with TLP)
    ../../nixos/hyprland.nix # Hyprland compositor from flake input
    ../../nixos/docker.nix # Docker + user added to docker group (not on sora)
    ../../nixos/amd-graphics.nix # RADV vulkan, VA-API, ROCm OpenCL

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
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];

  # Don't touch this
  system.stateVersion = "24.05";
}
