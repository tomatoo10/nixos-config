# Nix configuration for NixOS
{
  config,
  inputs,
  ...
}: let
  autoGarbageCollector = config.var.autoGarbageCollector;
in {
  # Allow the host user to run nixos-rebuild without a password; this is the only
  # core sudo exception. Normal sudo remains password-protected.
  security.sudo.extraRules = [
    {
      users = [config.var.username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };
  nix = {
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    channel.enable = false;
    extraOptions = ''
      warn-dirty = false
    '';
    settings = {
      download-buffer-size = 262144000; # 250 MB (250 * 1024 * 1024)
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        # Keep the binary cache list explicit so trusted substituters/keys stay reviewable.
        # high priority since it's almost always used
        "https://cache.nixos.org?priority=10"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://numtide.cachix.org"
        "https://noctalia.cachix.org"
        "https://quickshell.cachix.org"
        "https://nvf.cachix.org"
        "https://notashelf.cachix.org"
        "https://spicetify-nix.cachix.org"
        "https://cache.numtide.com"
        "https://codex-cli.cachix.org"
        "https://claude-code.cachix.org"
      ];
      trusted-substituters = ["https://hyprland.cachix.org"];
      # Pair the extra caches above with their public keys here.
      trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "quickshell.cachix.org-1:vBm3s5tZThc5KDLj6zhHVCMp8wX/AZJwle9wqdi81ts="
        "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="
        "notashelf.cachix.org-1:VTTBFNQWbfyLuRzgm2I7AWSDJdqAa11ytLXHBhrprZk="
        "spicetify-nix.cachix.org-1:jjnwULkvMdu0E5KGBbtgrISEfDdJTGSZ4ATkiFzZn5I="
        "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      ];
    };
    gc = {
      automatic = autoGarbageCollector;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
