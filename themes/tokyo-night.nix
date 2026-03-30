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
      base00 = "1a1b26"; # Default Background
      base01 = "16161e"; # Lighter Background
      base02 = "2f3549"; # Selection Background
      base03 = "444b6a"; # Comments, Invisibles
      base04 = "787c99"; # Dark Foreground
      base05 = "a9b1d6"; # Default Foreground
      base06 = "cbccd1"; # Light Foreground
      base07 = "d5d6db"; # Light Background
      base08 = "f7768e"; # Variables, Diff Deleted (red)
      base09 = "ff9e64"; # Integers, Constants (orange)
      base0A = "e0af68"; # Classes, Search Background (yellow)
      base0B = "9ece6a"; # Strings, Diff Inserted (green)
      base0C = "73daca"; # Support, Escape Characters (teal)
      base0D = "7aa2f7"; # Functions, Headings, Accent (blue)
      base0E = "bb9af7"; # Keywords, Markup Italic (purple)
      base0F = "db4b4b"; # Deprecated (dark red)
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
    image = ./wallpapers/samurai.jpg;
    # anotherhadi is down
    # image = pkgs.fetchurl {
    #   url = "https://raw.githubusercontent.com/anotherhadi/awesome-wallpapers/refs/heads/main/app/static/wallpapers/aquarium_blue.png";
    #   sha256 = "sha256-m6bk/1tQ8+kBr5GnLEUow6ZAFO5sdQYi5/yyiIDawqc=";
    # };
  };
}
