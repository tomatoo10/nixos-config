# Systemd-boot configuration for NixOS
{
  pkgs,
  lib,
  ...
}:
{
  # Bootloader.
  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot = {
    enable = lib.mkForce false;
    # consoleMode = "max";
    # editor = false;

    # extraEntries = {
    #   "windows.conf" = ''
    #     title   Windows
    #     efi     /EFI/Microsoft/Boot/bootmgfw.efi
    #   '';
    # };
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

}
