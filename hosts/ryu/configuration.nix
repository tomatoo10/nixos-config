{
  config,
  lib,
  ...
}: {
  imports = [
    # Mostly system related configuration
    ../../nixos/audio.nix
    ../../nixos/fonts.nix
    ../../nixos/home-manager.nix
    ../../nixos/nix.nix
    ../../nixos/lanzaboote.nix
    ../../nixos/sddm.nix
    ../../nixos/users.nix
    ../../nixos/utils.nix
    ../../nixos/hyprland.nix
    ../../nixos/docker.nix
    ../../nixos/amd-graphics.nix

    # You should let those lines as is
    ./hardware-configuration.nix
    ./variables.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  # Allow edit of /etc/hosts bc of HTB machines
  environment.etc.hosts.enable = lib.mkForce false;
  environment.etc.hosts.mode = lib.mkForce "0700";
  networking.firewall.enable = false;

  # Don't touch this
  system.stateVersion = "24.05";
}
