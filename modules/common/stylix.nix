{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    image = ../../wallpapers/light_anm07.png;
    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-mono;
        name = "CaskaydiaCove Nerd Font Mono";
      };
    };

    fonts.sizes = {
      applications = 12;
      terminal = 12;
      desktop = 10;
      popups = 12;
    };

    targets = {
      waybar.enable = true;
      waybar.addCss = true;
    };
  };
}
