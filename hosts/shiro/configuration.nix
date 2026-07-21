# shiro is the headless home server; this file assembles core NixOS modules plus the media/DNS stack, while app databases and most WebUI settings stay stateful and documented under hosts/shiro/media/docs.
{config, ...}: {
  # shiro assembles the headless/home-server modules here, including the media stack imports below.
  imports = [
    ../../modules/core/home-manager.nix
    ../../modules/core/nix.nix
    ../../modules/core/openssh.nix
    ../../modules/core/users.nix
    ../../modules/boot/systemd-boot.nix

    ./hardware-configuration.nix
    ./variables.nix

    ./networking.nix
    ./networking/firewall.nix
    ./storage.nix
    ./system.nix
    ./media/common.nix
    ./media/qbittorrent.nix
    ./media/qbittorrent/plex-limiter.nix
    ./media/arr.nix
    ./media/plex.nix
    ./media/containers.nix
    ./media/pihole.nix
    ./media/public-requests.nix
  ];

  home-manager.users."${config.var.username}" = import ./home.nix;

  system.stateVersion = "26.05";
}
