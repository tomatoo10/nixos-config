{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = ["tailnet-hosts"];
  };

  home.file.".ssh/tailnet-hosts" = {
    text = ''
      Host ryu ryu.ts
        HostName 100.101.164.47
        User ak4m3
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host sora sora.ts
        HostName 100.85.193.47
        User ak4m3
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host shiro shiro.ts
        HostName 100.110.91.84
        User tomato
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host shiro.lan
        HostName 192.168.18.7
        User tomato
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host ryu.lan
        HostName 192.168.18.4
        User ak4m3
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host *
        AddKeysToAgent yes
        Compression no
        HashKnownHosts yes
        ServerAliveInterval 30
        ServerAliveCountMax 3
    '';
  };
}
