# ThinkPad T14 Gen1 AMD (Ryzen PRO 4750U / Zen 2 "Renoir")
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "power-mode";
      runtimeInputs = with pkgs; [coreutils gnugrep tlp];
      text = ''
        set -euo pipefail

        require_root() {
          if [ "$(id -u)" -ne 0 ]; then
            echo "power-mode must run as root. Use: sudo power-mode <performance|balanced|low-power|status>" >&2
            exit 1
          fi
        }

        set_platform_profile() {
          local profile="$1"
          local profile_path="/sys/firmware/acpi/platform_profile"

          if [ -w "$profile_path" ]; then
            echo "$profile" > "$profile_path"
          fi
        }

        set_governor() {
          local governor="$1"

          for governor_path in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            [ -w "$governor_path" ] || continue
            echo "$governor" > "$governor_path"
          done
        }

        set_boost() {
          local enabled="$1"
          local boost_path="/sys/devices/system/cpu/cpufreq/boost"

          if [ -w "$boost_path" ]; then
            echo "$enabled" > "$boost_path"
          fi
        }

        show_status() {
          printf "platform_profile: "
          cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo "unavailable"

          printf "governor: "
          cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unavailable"

          printf "boost: "
          cat /sys/devices/system/cpu/cpufreq/boost 2>/dev/null || echo "unavailable"

          printf "temperature: "
          if [ -r /proc/acpi/ibm/thermal ]; then
            grep -oE -- "-?[0-9]+" /proc/acpi/ibm/thermal | head -n1 | tr -d "\n"
            echo " C"
          else
            echo "unavailable"
          fi

          printf "fan: "
          if [ -r /proc/acpi/ibm/fan ]; then
            grep -E "^(level|speed):" /proc/acpi/ibm/fan | tr "\n" " "
            echo
          else
            echo "unavailable"
          fi
        }

        mode="''${1:-status}"

        case "$mode" in
          performance)
            require_root
            tlp ac >/dev/null 2>&1 || true
            set_platform_profile performance
            set_governor performance
            set_boost 1
            ;;
          balanced)
            require_root
            set_platform_profile balanced
            set_governor schedutil
            set_boost 1
            ;;
          low-power)
            require_root
            set_platform_profile low-power
            set_governor powersave
            set_boost 0
            ;;
          status)
            show_status
            exit 0
            ;;
          *)
            echo "Usage: power-mode <performance|balanced|low-power|status>" >&2
            exit 2
            ;;
        esac

        show_status
      '';
    })
  ];

  security.sudo.extraRules = [
    {
      users = [config.var.username];
      commands = [
        {
          command = "/run/current-system/sw/bin/power-mode";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  boot.initrd.availableKernelModules = ["nvme" "ehci_pci" "xhci_pci_renesas" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.systemd.enable = true;
  boot.kernelModules = ["kvm-amd" "thinkpad_acpi"];
  # NOTE: no amd_pstate — Zen 2 BIOS lacks CPPC support, falls back to acpi-cpufreq.
  # acpi_backlight=native and psmouse.synaptics_intertouch=0 are set by the
  # nixos-hardware lenovo-thinkpad-t14-amd-gen1 module (flake.nix); not repeated here.
  boot.kernelPackages = pkgs.linuxPackages_zen;
  hardware.trackpoint.enable = lib.mkDefault true;
  hardware.trackpoint.emulateWheel = lib.mkDefault config.hardware.trackpoint.enable;

  # Managed Btrfs swapfile so hibernation works without repartitioning.
  # systemd-hibernate-resume can recover the exact swapfile location from the
  # UEFI HibernateLocation variable on the next boot.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 14336; # 14 GiB for the T14's RAM size
      discardPolicy = "both";
    }
  ];

  services.fwupd.enable = true;

  # TLP for laptop power management (conflicts with power-profiles-daemon)
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling - acpi-cpufreq (amd_pstate has no CPPC support on Zen 2)
      CPU_SCALING_DRIVER = "acpi-cpufreq";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;

      # Platform profile
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # PCIe ASPM
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      # WiFi power save
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # USB autosuspend
      USB_AUTOSUSPEND = 1;

      # Disk
      DISK_DEVICES = "nvme0n1";
      DISK_APM_LEVEL_ON_AC = "254";
      DISK_APM_LEVEL_ON_BAT = "128";

      # Keep the pack away from sustained high state-of-charge while still
      # leaving enough headroom for portable use.
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Thinkfan for fan control
  services.thinkfan = {
    enable = true;
    sensors = [
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/thermal";
      }
    ];
    fans = [
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/fan";
      }
    ];
    # [fan_level low_temp high_temp] — aggressive curve for gaming; hits full speed by 67°C
    levels = [
      [0 0 45]
      [1 40 52]
      [2 48 58]
      [3 54 63]
      [6 60 67]
      [7 65 32767]
    ];
  };

  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
