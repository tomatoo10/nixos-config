{
  config,
  lib,
  ...
}: {
  imports = [
    # Shared modules (same as ryu)
    ../../modules/core/home-manager.nix
    ../../modules/core/nix.nix # Flakes, caches, and garbage collection
    ../../modules/core/users.nix
    ../../modules/boot/secure-boot.nix # Lanzaboote secure boot using /var/lib/sbctl
    ../../modules/desktop/audio.nix # PipeWire audio stack
    ../../modules/desktop/display-manager.nix # SDDM login screen
    ../../modules/desktop/fonts.nix
    ../../modules/desktop/hyprland.nix # Hyprland compositor from flake input
    ../../modules/desktop/workstation-base.nix # Desktop services, portals, packages, locale
    ../../modules/gaming/steam.nix # Steam, Proton-GE, GameMode, Gamescope
    ../../modules/hardware/amd-gpu.nix # RADV Vulkan, VA-API, ROCm OpenCL

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
  services.resolved.settings.Resolve = {
    LLMNR = "no";
    MulticastDNS = "no";
  };
  services.avahi.enable = lib.mkForce false;

  # Laptop policy: sora can initiate SSH connections, but should not accept
  # inbound OpenSSH connections from LAN or tailnet peers.
  services.openssh.enable = lib.mkForce false;

  # Tailscale mesh VPN
  services.tailscale = {
    enable = true;
    extraSetFlags = ["--ssh=true" "--accept-dns=true"];
  };
  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.nameservers = ["192.168.18.1"];

  # Idle hibernate and suspend-then-hibernate for lid close.
  services.logind.settings.Login = {
    IdleAction = "hibernate";
    IdleActionSec = "90min";
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspendThenHibernate = true;
    HibernateDelaySec = "2h";
  };

  # Don't touch this
  system.stateVersion = "24.05";

  environment.etc.hosts.enable = lib.mkForce false;
  environment.etc.hosts.mode = lib.mkForce "0700";
  networking.firewall.enable = false;
}
