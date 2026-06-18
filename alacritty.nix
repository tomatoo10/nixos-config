{
  pkgs,
  lib,
  ...
}: {
  programs.alacritty = let
    fontFamily = "GohuFont 14 Nerd Font Mono";
  in {
    enable = true;
    settings = {
      general.import = ["${pkgs.alacritty-theme}/share/alacritty-theme/gruvbox_dark.toml"];

      terminal.shell = {
        program = "${pkgs.fish}/bin/fish";
      };

      font = {
        normal = {
          family = lib.mkForce fontFamily;
          style = "Regular";
        };
        bold = {
          family = lib.mkForce fontFamily;
          style = "Bold";
        };
        italic = {
          family = lib.mkForce fontFamily;
          style = "Italic";
        };
        bold_italic = {
          family = lib.mkForce fontFamily;
          style = "Bold Italic";
        };
        size = lib.mkForce 11;
      };

      keyboard = {
        bindings = [
          {
            key = "Return";
            mods = "Control|Shift";
            action = "CreateNewWindow";
          }
        ];
      };
    };
  };
}
