{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ./services.nix
    ./snapshot.nix
    ./packages.nix

    # Flakes
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
  ];

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 21d";
      };

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;

        # Cachix, avoid building binaries not available in nixcache.
        substituters = [
          "https://hyprland.cachix.org"
          "https://nix-community.cachix.org"
        ];

        # All substituters should be trusted if you want to pull from them
        trusted-substituters = [
          "https://cache.nixos.org/"
          "https://hyprland.cachix.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        extra-substituters = "https://devenv.cachix.org";
        extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
      };

      channel.enable = false;
      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Bootloader.
  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot = {
    enable = lib.mkForce false;
    # consoleMode = "max";
    # editor = false;

    # extraEntries = {
    #   "windows.conf" = ''
    #     title   Windows
    #     efi     /EFI/Microsoft/Boot/bootmgfw.efi
    #   '';
    # };
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Generation label
  system.nixos.label = "NixOS_${builtins.substring 6 8 config.system.nixos.version}";

  programs.nix-ld.enable = true;
  programs.command-not-found.enable = true;

  # 竜
  networking.hostName = "ryu";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    9001
    9002
    9003
    4444
    8080
    53317
  ];

  networking.firewall.allowedUDPPorts = [
    9001
    9002
    9003
    4444
    8080
    53317
  ];

  environment.etc.hosts.enable = false;
  environment.etc.hosts.mode = "0700";

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # System Wide user-settings
  users.users.ak4m3 = {
    isNormalUser = true;
    description = "ak4m3";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "input"
    ];
    home = "/home/ak4m3";
    uid = 1000;
    # TTY default shell
    shell = pkgs.fish;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "ak4m3";
  environment.variables.EDITOR = "nvim";
  nixpkgs.config.allowUnfree = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.opencl.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?
}
