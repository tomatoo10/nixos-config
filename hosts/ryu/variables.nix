{
  config,
  lib,
  ...
}: {
  imports = [
    # Choose your theme here:
    ../../themes/gruvbox-dark-medium.nix
  ];

  config.var = {
    hostname = "ryu";
    username = "ak4m3";
    configDirectory = "/home/" + config.var.username + "/.config/nixos"; # The path of the nixos configuration directory

    keyboardLayout = "us";

    # Allow edit of /etc/hosts bc of HTB machines
    environment.etc.hosts.enable = lib.mkForce false;
    environment.etc.hosts.mode = lib.mkForce "0700";
    networking.firewall.enaled = false;

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
