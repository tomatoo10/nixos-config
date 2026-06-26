{
  # Simple systemd-boot setup for hosts that do not use lanzaboote/Secure Boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
