{
  config,
  pkgs,
  ...
}: {
  programs.alacritty = let
    font_family = "GohuFont 14 Nerd Font Mono"; # Mono and not Propo because Propo height changes
  in {
    enable = true;
    settings = {
      general.import = [pkgs.alacritty-theme.gruvbox_dark];
      terminal.shell = "${pkgs.fish}/bin/fish";
      font = {
        normal = {
          family = font_family;
          style = "Regular";
        };
        bold = {
          family = font_family;
          style = "Bold";
        };
        italic = {
          family = font_family;
          style = "Italic";
        };
        bold_italic = {
          family = font_family;
          style = "Bold Italic";
        };
        size = 16;
      };

      keyboard = {
        bindings = [
          {
            key = "Return";
            mods = "Control|Shift";
            action = "SpawnNewInstance";
          }
        ];
      };
    };
  };
}
