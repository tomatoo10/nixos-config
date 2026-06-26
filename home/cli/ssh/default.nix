{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = ["tailnet-hosts"];
  };

  home.file.".ssh/tailnet-hosts" = {
    text = ''
      Host ryu ryu.ts
        HostName ryu
        User ak4m3
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host sora sora.ts
        HostName sora
        User ak4m3
        ForwardAgent no
        ServerAliveInterval 30
        ServerAliveCountMax 3

      Host shiro shiro.ts
        HostName shiro
        User tomato
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
