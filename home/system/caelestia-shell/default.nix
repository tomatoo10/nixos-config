# Caelestia Shell Home Manager Configuration
# See https://github.com/caelestia-dots/shell
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ./bar.nix
    ./launcher.nix
    ./appearance.nix
    ./scheme.nix
  ];

  programs.caelestia = {
    enable = true;
    systemd.enable = false;
    settings = {
      services.weatherLocation = "Guapimirim";
      general = {
        apps = {
          terminal = ["ghostty"];
          audio = ["pavucontrol"];
          explorer = ["thunar"];
        };
        idle = {
          timeouts = [];
        };
      };
    };
    cli = {
      enable = true;
      settings.theme = {
        enableTerm = false;
        enableDiscord = false;
        enableSpicetify = false;
        enableBtop = false;
        enableCava = false;
        enableHypr = false;
        enableGtk = false;
        enableQt = false;
      };
    };
  };

  home.packages = with pkgs; [
    gpu-screen-recorder
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "uwsm app -- caelestia resizer -d"
    "uwsm app -- caelestia shell -d"
    # caelestia is behaving weird with colors, sometimes you set the color and nothing changes. You need to change it back and forth to work, that's why we set it to onedark and later to custom.
    "caelestia scheme set -n onedark"
    "caelestia scheme set -n custom"
  ];

  services.cliphist = {
    enable = true;
    allowImages = true;
  };
}
