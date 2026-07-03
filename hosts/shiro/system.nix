# shiro system settings keep the low-memory home server stable with locale/time, zram, firmware, garbage collection, and lightweight operator packages.
{
  config,
  pkgs,
  ...
}: {
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModprobeConfig = ''
    # Keep the active Intel Wi-Fi card awake for server use.
    options iwlwifi power_save=0
  '';
  hardware.enableRedistributableFirmware = true;

  time.timeZone = config.var.timeZone;

  i18n = {
    defaultLocale = config.var.defaultLocale;
    extraLocaleSettings = {
      LC_ADDRESS = config.var.extraLocale;
      LC_IDENTIFICATION = config.var.extraLocale;
      LC_MEASUREMENT = config.var.extraLocale;
      LC_MONETARY = config.var.extraLocale;
      LC_NAME = config.var.extraLocale;
      LC_NUMERIC = config.var.extraLocale;
      LC_PAPER = config.var.extraLocale;
      LC_TELEPHONE = config.var.extraLocale;
      LC_TIME = config.var.extraLocale;
    };
  };

  console.keyMap = config.var.keyboardLayout;

  services.logind.settings.Login = {
    IdleAction = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # shiro is a server even though the hardware is laptop-like. Keep it online
  # with the lid closed and reject accidental/manual sleep requests that would
  # take media and storage services offline.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
    AllowHybridSleep = false;
  };

  # Prefer predictable plugged-in server performance over laptop power saving.
  powerManagement.cpuFreqGovernor = "performance";

  services.thermald.enable = true;

  # shiro is a low-memory laptop server. Prefer compressed RAM swap before
  # falling back to the slower disk swap partition during Plex transcodes or
  # concurrent Arr/Bazarr/Byparr activity.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  environment.systemPackages = with pkgs; [
    btop
    curl
    fastfetch
    git
    tailscale
    wget
  ];

  security.sudo.wheelNeedsPassword = true;

  documentation = {
    enable = true;
    doc.enable = false;
    dev.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };
}
