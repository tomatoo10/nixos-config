# My shell configuration
{
  pkgs,
  lib,
  config,
  ...
}: let
  fetch = config.theme.fetch; # neofetch, nerdfetch, pfetch
in {
  home.packages = with pkgs; [bat ripgrep tldr witr];

  programs.fish = {
    enable = true;

    shellInit = lib.optionalString (config.home.sessionPath != []) ''
      for p in ${lib.concatStringsSep " " config.home.sessionPath};
        fish_add_path --move --prepend $p
      end
    '';

    interactiveShellInit = ''
      # SWAP FISH AUTOSUGGESTION KEYS
      # TAB -> Accept suggestion
      bind \t accept-autosuggestion

      # Ctrl+F -> Show suggestions
      bind \cf complete

      bind alt-l 'clear; commandline -f repaint'

      # Remove greeting
      set fish_greeting
    '';

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      n = "nvim";
      v = "nvim";
      c = "clear";
      r = "y";
      ranger = "y";
      clera = "clear";
      celar = "clear";
      e = "exit";
      cd = "z";
      ls = "eza --icons=always --no-quotes";
      cfg = "cd ~/.config/nixos/";
      tree = "eza --icons=always --tree --no-quotes";
      sl = "ls";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
      cat = "bat --theme=base16 --color=always --paging=never --tabs=2 --wrap=never --plain";
      mkdir = "mkdir -p";

      # Git
      gcl = "git clone";
      gst = "git status";
      gti = "git";
      checkpoint = "git add . && git commit";
      lola = "git log --graph --pretty=\"format:%C(auto)%h %d %s %C(green)(%ad) %C(cyan) <%an >\" --abbrev-commit --all --date=relative";

      g = "lazygit";
      ga = "git add";
      gc = "git commit";
      gcu = "git add . && git commit -m 'Update'";
      gp = "git push";
      gpl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gcb = "git checkout -b";
      gbr = "git branch";
      grs = "git reset HEAD~1";
      grh = "git reset --hard HEAD~1";

      gaa = "git add .";
      gcm = "git commit -m";

      # Nix
      # nhhm = "nh home switch /etc/nixos#homeConfigurations.ak4m3@$1.activationPackage";
      nhos = "nh os switch /etc/nixos";

      # Servers and Vm's
      sharedwin = "cd ~/.akame/sharedwin/";
      mount_server = "sudo sshfs -o allow_other,default_permissions,kernel_cache,cache=yes akame@192.168.1.100:/home/akame/ ~/misc/server/ -p 2222";
      mount_share = "sudo sshfs -o allow_other,default_permissions,kernel_cache,cache=yes akame@192.168.1.100:/home/shared/ ~/misc/home-server/ -p 2222";

      # Rust ;
      cargo_build_win = "cargo build --target x86_64-pc-windows-gnu";
      lint = "./lint.sh";
      clippy = "cargo clippy -- -A clippy::all";

      obsidian-no-gpu = "env ELECTRON_OZONE_PLATFORM_HINT=auto obsidian --ozone-platform=x11";
      wireguard-import = "nmcli connection import type wireguard file";
      df = "duf -hide-fs squashfs";
    };

    functions = {
      mount_server = ''
        mkdir -p ~/mnt/server
        sshfs -p 2222 \
          -o allow_other,default_permissions,kernel_cache,cache=yes,reconnect \
          akame@192.168.1.100:/home/akame/ ~/mnt/server
      '';

      mount_share = ''
        mkdir -p ~/mnt/shared
        sshfs -p 2222 \
          -o allow_other,default_permissions,kernel_cache,cache=yes,reconnect \
          akame@192.168.1.100:/home/shared/ ~/mnt/shared
      '';

      umount_server = ''
        fusermount3 -u ~/mnt/server
      '';

      umount_share = ''
        fusermount3 -u ~/mnt/shared
      '';
    };
  };
}
