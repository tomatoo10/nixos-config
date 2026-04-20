{
  lib,
  pkgs,
  config,
  ...
}: {
  options.theme = lib.mkOption {
    type = lib.types.attrs;
    default = {
      rounding = 8;
      gaps-in = 6;
      gaps-out = 12;
      active-opacity = 0.99;
      inactive-opacity = 0.97;
      blur = true;
      border-size = 2;
      animation-speed = "fast";
      fetch = "none";
      textColorOnWallpaper = config.lib.stylix.colors.base05;
    };
    description = "Theme configuration options";
  };
  config.stylix = {
    enable = true;
    base16Scheme = {
      base00 = "282828"; # Default Background
      base01 = "3c3836"; # Lighter Background
      base02 = "504945"; # Selection Background
      base03 = "665c54"; # Comments, Invisibles
      base04 = "bdae93"; # Dark Foreground
      base05 = "d5c4a1"; # Default Foreground
      base06 = "ebdbb2"; # Light Foreground
      base07 = "fbf1c7"; # Light Background
      base08 = "fb4934"; # Variables, Diff Deleted (red)
      base09 = "fe8019"; # Integers, Constants (orange)
      base0A = "fabd2f"; # Classes, Search Background (yellow)
      base0B = "b8bb26"; # Strings, Diff Inserted (green)
      base0C = "8ec07c"; # Support, Escape Characters (teal)
      base0D = "83a598"; # Functions, Headings, Accent (blue)
      base0E = "d3869b"; # Keywords, Markup Italic (purple)
      base0F = "d65d0e"; # Deprecated (dark red)
    };
    cursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 20;
    };
    fonts = {
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";
      };
      sansSerif = {
        package = pkgs.source-sans-pro;
        name = "Source Sans Pro";
      };
      serif = config.stylix.fonts.sansSerif;
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 13;
        desktop = 13;
        popups = 13;
        terminal = 13;
      };
    };
    polarity = "dark";
    image = ./wallpapers/another-planet-with-grass_blue.png;
  };
}
