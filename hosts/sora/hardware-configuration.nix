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

  boot.initrd.availableKernelModules = ["nvme" "ehci_pci" "xhci_pci_renesas" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"];
  boot.kernelModules = ["kvm-amd" "thinkpad_acpi"];
  # NOTE: no amd_pstate — Zen 2 BIOS lacks CPPC support, falls back to acpi-cpufreq
  # psmouse.synaptics_intertouch=0 fixes erratic touchpad on this model
  boot.kernelParams = ["acpi_backlight=native" "psmouse.synaptics_intertouch=0"];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  hardware.trackpoint.enable = lib.mkDefault true;
  hardware.trackpoint.emulateWheel = lib.mkDefault config.hardware.trackpoint.enable;

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

      # Battery charge thresholds (ThinkPad specific, preserves battery longevity)
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 85;
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
    # [fan_level low_temp high_temp] — tune after checking `sensors` output
    levels = [
      [0 0 55]
      [1 48 60]
      [2 53 65]
      [3 58 70]
      [6 63 75]
      [7 68 80]
      ["level auto" 75 32767]
    ];
  };

  networking.wireless.enable = false;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.bluetooth.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
