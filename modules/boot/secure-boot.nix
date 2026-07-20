# Secure Boot configuration through lanzaboote.
#
# Firmware/key enrollment is still a host-local, manual operation. Nix only
# builds signed UKIs once sbctl has keys available in /var/lib/sbctl.
#
# Enablement checklist for a host that imports this module:
#
# 1. Inspect current Secure Boot/signing state:
#      sudo sbctl status
#      sudo sbctl verify
#
# 2. If sbctl keys do not exist yet, create them:
#      sudo sbctl create-keys
#
# 3. Put firmware into Setup Mode by clearing/resetting existing Secure Boot
#    keys from the BIOS/UEFI setup screen.
#
# 4. Enroll keys. Keep Microsoft keys if Windows Boot Manager, Microsoft-signed
#    option ROMs, or other Microsoft-signed loaders should continue to work:
#      sudo sbctl enroll-keys --microsoft
#
# 5. Rebuild after enrollment so lanzaboote signs the active generation:
#      sudo nixos-rebuild switch --flake ~/.config/nixos#<hostname>
#
# 6. Reboot into firmware and enable Secure Boot.
#
# 7. Verify after boot:
#      bootctl status
#      sudo sbctl status
#      sudo sbctl verify
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
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

}
