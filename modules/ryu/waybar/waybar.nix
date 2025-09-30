{
  config,
  ...
}:
let
  colors = config.lib.stylix.colors;

  customColors = {
    fg-main = colors.base05;
    fg-unactive = colors.base05;
    bg-main = colors.base00;
    bg-second = colors.base01;
    bg-third = colors.base02;
    bg-third2 = colors.base02;
    bg-hover = colors.base01;
    bg-tooltip = colors.base01;
    border-main = colors.base05;
    warning_color = colors.base0A;
    bluetooth_on_color = "6f7dd8";
    bluetooth_off_color = "565858";
  };
in
{
  xdg.configFile."waybar/config" = {
    source = ./binary/config;
  };

  programs.waybar = {
    enable = true;
    style = ''
      * {
        all: unset;
        font-family: "JetBrainsMono Nerd Font", "Fira Mono";
        font-weight: 700;
        font-size: 12.5px;
      }

      window#waybar {
        /* Corrected: Use individual RGB components as the attribute names have changed */
        background: rgba(${toString colors.base00-rgb-r}, ${toString colors.base00-rgb-g}, ${toString colors.base00-rgb-b}, 0);
        color: #${customColors.fg-main};
      }

      tooltip {
        background: #${customColors.bg-tooltip};
        border-radius: 5px;
        border-width: 1px;
        border-style: solid;
        border-color: #${customColors.border-main};
      }
      tooltip label {
        color: #${customColors.fg-main};
      }

      #custom-swaync {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 1px;
        color: #${customColors.fg-main};
        background-color: #${customColors.bg-main};
        min-width: 20px;
        padding-left: 12px;
        padding-right: 12px;
        margin-left: 10px;
        margin-right: 5px;
        transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
        border: 2px solid #${customColors.border-main};
        border-radius: 10px;
      }

      #workspaces {
        color: transparent;
        margin-right: 1.5px;
        margin-left: 1.5px;
        border-radius: 12px;
        border: 2px solid #${customColors.border-main};
        background-color: #${customColors.bg-main};
        padding: 0px 20px
      }
      #workspaces button {
        color: #${customColors.fg-unactive};
        padding: 2px 10px;
        margin: 3px 4px;
        background-color: #${customColors.bg-third};
        border-radius: 10px;
        border-color: #${customColors.bg-main};
      }

      #workspaces button.active {
        color: #${customColors.bg-main};
        border-radius: 8px;
        background: #${customColors.fg-main};
        padding: 0px 20px;
      }
      #workspaces button.focused {
        color: #${customColors.bg-second};
      }
      #workspaces button.urgent {
        background: rgba(255, 200, 0, 0.35);
        border-bottom: 0px dashed #${customColors.warning_color};
        color: #${customColors.warning_color};
      }
      #workspaces button:hover {
        background: #${customColors.fg-main};
        color: #${customColors.bg-main};
      }

      #cpu, #disk, #memory {
        padding: 3px;
      }

      #window {
        border-radius: 10px;
        margin-left: 20px;
        margin-right: 20px;
      }

      #bluetooth {
        padding: 0px 10px;
        font-size: 14px;
        font-family: "Fira Code";
      }

      #bluetooth.disabled, #bluetooth.off {
        color: #${customColors.bluetooth_off_color};
      }
      #bluetooth.on, #bluetooth.connected {
        color: #${customColors.bluetooth_on_color};
      }

      #custom-swaync {
        font-size: 20px;
        padding: 0px 8px;
        padding-right: 13px;
      }

      #power-profiles-daemon {
        background-color: #${customColors.bg-main};
        color: #${customColors.fg-main};
        padding: 0px 5px;
        padding-left: 10px;
        font-size: 14px;
        border-radius: 10px;
        margin: 2px 6px;
        transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
      }

      #cpu, #memory, #custom-search, #custom-os_button, #custom-runner, #mpris, #custom-cafein, #cava, #clock {
        font-family: "Symbols Nerd Font", "JetbrainsMono Nerd Font";
        background-color: #${customColors.bg-main};
        font-weight: bold;
        border-radius: 16px;
        padding: 0px 10px;
        border: 0px solid #${customColors.border-main};
        transition: all 0.25s cubic-bezier(0.165, 0.84, 0.44, 1);
      }

      #mpris {
        border: 2px solid #${customColors.border-main};
        border-radius: 10px;
        margin: 0px 10px;
        background-color: #${customColors.bg-main};
        padding: 0px 10px;
        padding-left: 2px;
      }

      #custom-swaync:hover, #tray > widget:hover, #custom-search:hover, #custom-os_button:hover, #custom-runner:hover, #mpris:hover, #custom-cafein:hover, #clock:hover, #power-profiles-daemon:hover {
        background-color: #${customColors.bg-hover};
      }

      #hardware {
        background-color: #${customColors.bg-second};
        font-weight: bold;
        padding: 0px 10px;
        margin: 2px 0px;
        border-radius: 10px;
      }

      #cpu, #memory {
        background-color: unset;
      }

      #bluetooth {
        font-size: 15px;
      }

      #leftSide {
        border: 2px solid #${customColors.border-main};
        border-radius: 10px;
        margin: 0px 10px;
        background-color: #${customColors.bg-main};
        padding: 0px 10px;
      }

      #rightSide {
        border: 2px solid #${customColors.border-main};
        border-radius: 10px;
        margin: 0px 10px;
        background-color: #${customColors.bg-main};
        padding: 0px 10px;
        padding-left: 2px;
      }

      #clock {
        font-size: 14px;
        padding: 0px 6px;
        margin: 0px 4px;
      }

      #controlCenter {
        background-color: #${customColors.bg-second};
        border-radius: 15px;
        padding: 0px 8px;
        margin: 0px 10px;
      }

      #controlCenter:hover {
        background-color: #${customColors.bg-third};
      }

      #network, #pulseaudio, #battery, #backlight {
        padding: 0px 6px;
        font-size: 15px;
      }
    '';
  };
}
