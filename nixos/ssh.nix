{config, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
      X11Forwarding = false;
    };
  };

  users.users."${config.var.username}".openssh.authorizedKeys.keys = [
    # ak4m3@ryu
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGX6FvImga1DxWYLX+md5E/LgGsjqT/Qk92pdy+BU94U mooraesz123@gmail.com"
    # ak4m3@sora
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRyggw/vCxPa/8MJRPcQ0ZVVc8SPhO3blJnXZFcVVBC mooraesz123@gmail.com"
    # tomato@shiro
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH/nA9sXfQj+oncRQV0uCFxdbQx/vUREoBKYf2Zcz95k tomato@shiro"
  ];
}
