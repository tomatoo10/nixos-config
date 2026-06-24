{
  config,
  inputs,
  pkgs,
  ...
}: let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGX6FvImga1DxWYLX+md5E/LgGsjqT/Qk92pdy+BU94U mooraesz123@gmail.com";
in {
  imports = [
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/users.nix
    ../../nixos/docker.nix

    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModprobeConfig = ''
    # Keep Intel Wi-Fi awake for a server workload. The Realtek USB adapter is
    # currently disconnected, but this helps the active iwlwifi card.
    options iwlwifi power_save=0
  '';
  hardware.enableRedistributableFirmware = true;

  networking = {
    hostName = config.var.hostname;
    useDHCP = false;
    wireless.enable = false;
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = false;
        };
        Settings.AutoConnect = true;
      };
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
      trustedInterfaces = ["tailscale0"];
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = true;
    networks."10-wifi" = {
      # Match the active Wi-Fi interface even if udev gives it a different
      # predictable name after switching Wi-Fi managers/kernel versions.
      matchConfig.Name = "wl*";
      address = ["192.168.18.7/24"];
      gateway = ["192.168.18.1"];
      dns = ["192.168.18.1" "1.1.1.1"];
      networkConfig = {
        IPv6AcceptRA = true;
        LinkLocalAddressing = "ipv6";
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      LLMNR = "no";
      MulticastDNS = "no";
    };
  };

  time.timeZone = config.var.timeZone;

  i18n = {
    defaultLocale = config.var.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = config.var.extraLocale;
      LC_IDENTIFICATION = config.var.extraLocale;
      LC_MEASUREMENT = config.var.extraLocale;
      LC_MONETARY = config.var.extraLocale;
      LC_NAME = config.var.extraLocale;
      LC_NUMERIC = config.var.extraLocale;
      LC_PAPER = config.var.extraLocale;
      LC_TELEPHONE = config.var.extraLocale;
      LC_TIME = config.var.extraLocale;
    };
  };

  console.keyMap = config.var.keyboardLayout;

  services = {
    openssh = {
      enable = true;
      settings = {
        # Keep password login for the bootstrap switch. We can harden this to
        # false after confirming the flake-managed SSH key login survives reboot.
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    tailscale = {
      enable = true;
      extraSetFlags = ["--ssh=true"];
    };
    thermald.enable = true;
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = ["/"];
    };
  };

  systemd.services.btrfs-balance-shiro = {
    description = "Light Btrfs balance for shiro";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      ${pkgs.btrfs-progs}/bin/btrfs balance start -dusage=75 -musage=75 /
    '';
  };

  systemd.timers.btrfs-balance-shiro = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "6h";
    };
  };

  users.users."${config.var.username}".openssh.authorizedKeys.keys = [sshKey];

  environment.systemPackages = with pkgs; [
    btop
    curl
    fastfetch
    git
    tailscale
    wget
  ];

  security.sudo.wheelNeedsPassword = false;

  documentation = {
    enable = true;
    doc.enable = false;
    dev.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  system.stateVersion = "26.05";
}
