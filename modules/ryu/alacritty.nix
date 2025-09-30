{
  pkgs,
  lib,
  ...
}:
{
  programs.alacritty =
    let
      font_family = lib.mkForce "GohuFont 14 Nerd Font Mono";
    in
    {
      enable = true;
      settings = {
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
          size = lib.mkForce 11;
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
