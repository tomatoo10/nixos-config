{config, ...}: {
  imports = [
    ../../modules/core/home-manager.nix
    ../../modules/core/nix.nix
    ../../modules/core/openssh.nix
    ../../modules/core/users.nix
    ../../modules/boot/systemd-boot.nix

    ./hardware-configuration.nix
    ./variables.nix

    ./networking.nix
    ./storage.nix
    ./system.nix
    ./media/common.nix
    ./media/qbittorrent.nix
    ./media/arr.nix
    ./media/recyclarr.nix
    ./media/plex.nix
    ./media/containers.nix
    ./media/qui.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "26.05";
}
