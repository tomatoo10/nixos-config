{
  config,
  lib,
  ...
}: {
  imports = [
    # Choose your theme here:
    ../../themes/tokyo-night.nix
  ];

  config.var = {
    hostname = "sora";
    username = "ak4m3";
    configDirectory = "/home/" + config.var.username + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "us";
    # keyboardLayout = "br-abnt2";

    networking.wireless.enable = false;
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    location = "Guapimirim";
    timeZone = "America/Sao_Paulo";
    defaultLocale = "en_US.UTF-8";
    extraLocale = "pt_BR.UTF-8";

    git = {
      username = "akamee666";
      email = "moraes@akmee.xyz";
    };

    autoUpgrade = false;
    autoGarbageCollector = true;
  };

  # DON'T TOUCH THIS
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
