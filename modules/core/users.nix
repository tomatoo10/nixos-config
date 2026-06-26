# Users configuration for NixOS
{
  config,
  pkgs,
  ...
}: let
  username = config.var.username;
in {
  programs.fish.enable = true;
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  users = {
    defaultUserShell = pkgs.fish;
    users.${username} = {
      isNormalUser = true;
      description = "${username} account";
      extraGroups = ["networkmanager" "wheel" "input"];
    };
  };
}
