{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    base16Scheme = ../../themes/red.yaml;

    targets.alacritty.enable = false;
    targets.fish.enable = false;
    targets.yazi.enable = false;
  };
}
