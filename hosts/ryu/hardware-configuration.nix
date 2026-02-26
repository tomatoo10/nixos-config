{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    # Webcam
    "uvcvideo"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  powerManagement.cpuFreqGovernor = "performance";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/663eabbc-eef2-43db-8e7f-cae986188d9d";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/663eabbc-eef2-43db-8e7f-cae986188d9d";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    neededForBoot = true;
    device = "/dev/disk/by-uuid/663eabbc-eef2-43db-8e7f-cae986188d9d";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B889-D3EA";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
