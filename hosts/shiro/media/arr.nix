# Radarr/Sonarr/Bazarr/Prowlarr run natively for movies, TV/anime, subtitles, and indexer sync; this file owns enablement/firewall/group permissions while root folders, clients, profiles, and indexers are mostly WebUI/Profilarr/Prowlarr-owned.
{lib, pkgs, ...}: let
  bazarrSubtitleGuard = pkgs.writeShellApplication {
    name = "bazarr-subtitle-guard";
    runtimeInputs = [
      pkgs.ffmpeg
      pkgs.ffsubsync
      pkgs.python3
    ];
    text = ''
      exec python3 ${./scripts/bazarr-subtitle-guard.py} "$@"
    '';
  };
in {
  # Native Servarr apps. WebUI/API state is still app-owned; Nix owns enablement
  # and shared media-group permissions here. Firewall exposure is centralized in
  # hosts/shiro/networking so IPv6/global-address policy stays consistent.
  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = false;
  };
  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = false;
  };
  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = false;
    settings.server.bindaddress = "*";
  };
  services.prowlarr = {
    enable = true;
    openFirewall = false;
    settings.server.bindaddress = "*";
  };

  systemd.services = {
    # Radarr/Sonarr create media directories and Bazarr writes sidecar subtitle
    # files into them. Keep new files group-writable for the shared `media`
    # group instead of leaving them owner-only via the default 0022 umask.
    radarr.serviceConfig.UMask = lib.mkForce "0002";
    sonarr.serviceConfig.UMask = lib.mkForce "0002";
    bazarr = {
      path = [
        bazarrSubtitleGuard
        pkgs.ffmpeg
        pkgs.ffsubsync
      ];
      serviceConfig.UMask = lib.mkForce "0002";
    };
  };

  environment.systemPackages = [bazarrSubtitleGuard];
}
