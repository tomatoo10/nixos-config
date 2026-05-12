{
  config,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/audio.nix
    ../../nixos/amd-graphics.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/lanzaboote.nix
    ../../nixos/sddm.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/hyprland.nix
    ../../nixos/gaming.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./disko-config.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Don't touch this
  system.stateVersion = "24.05";

  environment.etc.hosts.enable = lib.mkForce false;
  environment.etc.hosts.mode = lib.mkForce "0700";
  networking.firewall.enable = false;
}
