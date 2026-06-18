{
  pkgs,
  config,
  ...
}: {
  programs.steam = {
    enable = true;
    # Proton-GE provides broader game compatibility than upstream Proton
    extraCompatPackages = [pkgs.proton-ge-bin];
    # Map XTest events to uinput for proper controller support under Wayland/XWayland
    extest.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
  # GameMode temporarily raises CPU/GPU performance during gaming sessions
  programs.gamemode = {
    enable = true;
    settings = {
      gpu = {
        # Sets amdgpu to high performance level while game runs, resets after
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  programs.gamescope = {
    enable = true;
    # Allow gamescope to use SCHED_NICE for real-time priority boosts
    capSysNice = true;
  };

  # Udev rules for Steam hardware: controllers, VR headsets, etc.
  hardware.steam-hardware.enable = true;

  # GameMode polkit rule requires group membership to allow priority escalation
  users.users.${config.var.username}.extraGroups = ["gamemode"];
}
