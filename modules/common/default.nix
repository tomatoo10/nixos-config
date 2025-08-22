{...}: {
  imports = [
    ./fish.nix # Shell
    ./helix.nix # Text editor when i get bored of neovim
    ./nh.nix # Nix cli helper
    ./rofi.nix # Application launcher
    ./stylix.nix # Used to color applications system-wide
    ./yazi.nix # Terminal file manager
  ];
}
