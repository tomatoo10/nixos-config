{ ... }:
{
  # Virtualisation, enable guest utilities
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.blueman.enable = true;

  # File system
  # Scrubbing - is the process of checking file consistency (for this it may use checksums and/or duplicated copies of data, from raid for example). Scrubbing may be done "online", meaning you don't need to unmount a subvolume to scrub it.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";
    configs = {
      root = {
        SUBVOLUME = "/";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = "0";
        TIMELINE_LIMIT_DAILY = "0";
        TIMELINE_LIMIT_WEEKLY = "0";
        TIMELINE_LIMIT_MONTHLY = "12";
        TIMELINE_LIMIT_YEARLY = "0"; # One snapshot per month, minor changes will be covered by nixos atomic build system.
        BACKGROUND_COMPARISON = "yes";
        NUMBER_CLEANUP = "yes";
        NUMBER_MIN_AGE = "1800";
        NUMBER_LIMIT = "12"; # Keep it under one year, will be used for major system roolbacks.
        NUMBER_LIMIT_IMPORTANT = "12";
        EMPTY_PRE_POST_CLEANUP = "yes";
        EMPTY_PRE_POST_MIN_AGE = "1800";
      };
      home = {
        /*
          Is this optimal? I don't know, my brain think it's
          [HOURLY]  snapshot from 1 hour ago
          [HOURLY]  snapshot from 2 hours ago
          ...
          [DAILY] snapshot from 1 day ago
          [DAILY] snapshot from 2 day ago
          ..
          [WEEKLY] snapshot from ~2weeks ago
          [WEEKLY] snapshot from ~3weeks ago
          ...
          [MONTHLY] snapshot from ~2 months ago
          [MONTHLY] snapshot from ~3 months ago

          ( Older than 8months are deleted )
        */
        SUBVOLUME = "/home";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = "24"; # List of snapshots taken each hour, usage would be if i delete something.
        TIMELINE_LIMIT_DAILY = "14"; # 2 Weeks olds snapshots.
        TIMELINE_LIMIT_WEEKLY = "4"; # 4 Week olds snapshots.
        TIMELINE_LIMIT_MONTHLY = "8"; # 8 Months old data.
        TIMELINE_LIMIT_YEARLY = "0";
        BACKGROUND_COMPARISON = "yes";
        NUMBER_CLEANUP = "yes";
        NUMBER_MIN_AGE = "1800";
        NUMBER_LIMIT = "80";
        NUMBER_LIMIT_IMPORTANT = "20";
        EMPTY_PRE_POST_CLEANUP = "yes";
        EMPTY_PRE_POST_MIN_AGE = "1800";
      };
    };
  };
}
