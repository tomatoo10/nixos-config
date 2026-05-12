{pkgs, ...}: {
  programs.steam = {
    enable = true;
    # Proton-GE provides broader game compatibility than upstream Proton
    extraCompatPackages = [pkgs.proton-ge-bin];
    # Map XTest events to uinput for proper controller support under Wayland/XWayland
    extest.enable = true;
  };

  # GameMode temporarily raises CPU/GPU performance during gaming sessions
  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    # Allow gamescope to use SCHED_NICE for real-time priority boosts
    capSysNice = true;
  };

  # Udev rules for Steam hardware: controllers, VR headsets, etc.
  hardware.steam-hardware.enable = true;
}
