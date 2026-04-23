{config, lib, ...}: {
  imports = [
    # Shared modules (same as ryu)
    ../../nixos/audio.nix # PipeWire audio stack
    ../../nixos/amd-graphics.nix # RADV vulkan, VA-API, ROCm OpenCL
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix # Flakes, cachix substituters, garbage collection
    ../../nixos/lanzaboote.nix # Secure Boot via lanzaboote (needs /var/lib/sbctl enrolled)
    ../../nixos/sddm.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix # NetworkManager, power-profiles-daemon (overridden by TLP in hw config), xdg portals
    ../../nixos/hyprland.nix # Hyprland compositor from flake input

    # NOTE: docker.nix not imported here unlike ryu — add if needed for dev work
    # NOTE: amd-graphics.nix uses ROCm which targets dGPU; sora's Vega iGPU supports it but perf is limited

    # Hardware and disk layout
    ./hardware-configuration.nix # TLP, thinkfan, iwd wifi, bluetooth, firmware — sora-specific
    ./disko-config.nix # LUKS + btrfs partitioning via disko
    ./variables.nix # Theme (tokyo-night), user, locale
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # WiFi hardening for public networks (airports, cafés)
  networking.networkmanager.settings = {
    device = {
      "wifi.scan-rand-mac-address" = "yes";
    };
    connection = {
      "wifi.cloned-mac-address" = "stable";
      "ethernet.cloned-mac-address" = "stable";
      "connection.stable-id" = "\${CONNECTION}/\${BOOT}";
      "ipv6.ip6-privacy" = "2";
      "ipv6.addr-gen-mode" = "stable-privacy";
    };
  };

  # Kill hostname broadcast protocols
  services.resolved.llmnr = "false";
  services.resolved.extraConfig = "MulticastDNS=no";
  services.avahi.enable = lib.mkForce false;

  # Tailscale mesh VPN
  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];

  # Don't touch this
  system.stateVersion = "24.05";
}
