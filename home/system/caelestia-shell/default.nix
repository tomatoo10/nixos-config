# Caelestia Shell Home Manager Configuration
# See https://github.com/caelestia-dots/shell
{
  pkgs,
  inputs,
  ...
}: let
  patchedCaelestiaShell = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.overrideAttrs (oldAttrs: {
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        batteryQml="$out/share/caelestia-shell/modules/bar/popouts/Battery.qml"
        substituteInPlace "$batteryQml" \
          --replace-fail "import Quickshell.Services.UPower" "import Quickshell
        import Quickshell.Services.UPower" \
          --replace-fail "onClicked: PowerProfiles.profile = parent.profile" "onClicked: {
                        const mode = parent.profile === PowerProfile.PowerSaver ? \"low-power\" : parent.profile === PowerProfile.Performance ? \"performance\" : \"balanced\";
                        Quickshell.execDetached([\"sudo\", \"power-mode\", mode]);
                        PowerProfiles.profile = parent.profile;
                    }"
      '';
  });

  startCaelestia = pkgs.writeShellApplication {
    name = "start-caelestia";
    runtimeInputs = with pkgs; [
      coreutils
    ];
    text = ''
      caelestia resizer -d &
      caelestia shell -d &

      # Caelestia sometimes loads the previous palette if the scheme is set
      # before the shell has finished initialising. Retry the selected Stylix
      # backed scheme while the shell comes up.
      for _ in $(seq 1 8); do
        caelestia scheme set -n custom >/dev/null 2>&1 || true
        sleep 0.75
      done
    '';
  };
in {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ./bar.nix
    ./launcher.nix
    ./appearance.nix
    ./scheme.nix
  ];

  programs.caelestia = {
    enable = true;
    package = patchedCaelestiaShell;
    systemd.enable = false;
    settings = {
      services.weatherLocation = "-22.53722,-42.98194";
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
    "uwsm app -- ${startCaelestia}/bin/start-caelestia"
  ];

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

}
