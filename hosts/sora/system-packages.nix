{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
    blueman
    zerotierone
  ];

  # fish config is manager responsible but shell is installed systemwide
  # programs.fish.enable = true;
  # enable home-manager and git
  programs.git.enable = true;
  programs.command-not-found.enable = true;
  programs.fish.enable = true;

  programs.hyprland = {
    enable = true;
  };

  # enable the xwayland compatibility layer for x11 applications
  programs.xwayland.enable = true;

  programs.ssh.extraConfig = ''
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
  '';
}
