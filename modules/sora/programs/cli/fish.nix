{
  lib,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      # General
      rl = "readlink -f";
      r = "y";
      ranger = "y";
      n = "nvim";
      nv = "nvim .";
      cls = "clear ; cd";
      logoff = "killall -u $USER";
      rm = "rm -I";
      rf = "rm -rf -I";
      b64 = "base64";
      bd = "base64 -d";
      md = "mkdir";
      chx = "chmod +x";
      rmexif = "exiftool -all=";
      cfg = "cd /etc/nixos/";
      diff = "difft";
      htop = "btop";
      find = "fd --color never";

      # Nix
      # nhhm = "nh home switch /etc/nixos#homeConfigurations.akame@$1.activationPackage";
      nhos = "nh os switch /etc/nixos";

      # Servers and Vm's
      sharedwin = "cd ~/.akame/sharedwin/";
      mountsshfs_homeserver = "sudo sshfs -o allow_other,default_permissions,kernel_cache,cache=yes akame@192.168.1.100:/home/akame/ ~/.akame/server/ -p 2222";
      mountsshfs_backup = "sudo sshfs -o allow_other,default_permissions,kernel_cache,cache=yes akame@192.168.1.100:/home/shared/ ~/.akame/home-backup/ -p 2222";

      # Rust ;
      cargo_build_win = "cargo build --target x86_64-pc-windows-gnu";
      lint = "./lint.sh";
      clippy = "cargo clippy -- -A clippy::all";

      # Git;
      gcl = "git clone";
      gst = "git status";
      checkpoint = "git add . && git commit";
      lola = "git log --graph --pretty=\"format:%C(auto)%h %d %s %C(green)(%ad) %C(cyan) <%an >\" --abbrev-commit --all --date=relative";
      # Better output;
      du = "dust";
      ip = "ip -color=auto";
      dmesg = "dmesg --color=always";
      cat = "bat --plain --decorations never --paging never";
      catp = "bat --paging always";
      df = "duf -hide-fs squashfs";
      free = "free -h";
      # Shells;
      b = "bash";
      f = "fish";
      # Changing keyboard layout;
      setbr = "setxkbmap -layout br";
      setus = "setxkbmap -layout us";
      # Fast edit/read configs;
      efconf = "nvim /etc/nixos/";
      # Grep;
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      gp = "grep";
      hg = "history | grep $1";
      # Networking tools;
      ifme = "curl ifconfig.me";
      ssp = "ss -tupan | grep $1";
      nethogs = "sudo nethogs";
      iftop = "sudo iftop";
      mm = "mitmproxy";
      # Visual configs;
      panes = "/opt/shell-color-scripts/colorscripts/panes";
      fehbgr = "feh --bg-fill $(shuf -n 1 -e ~/Pictures/wallpapers/dark/*) --bg-fill ~/Pictures/wallpapers/justblack.jpg";
      frenzch = "~/frenzch.sh/frenzch.sh";
      clock = "tty-clock -c -C4";
      # "ls" to "eza";
      sl = "ls";
      ls = "eza --icons --color=always --group-directories-first";
      l = "eza --icons --color=always --group-directories-first";
      la = "eza --icons -laF --octal-permissions --color=always --group-directories-first";
      ll = "eza --icons -lF --octal-permissions --color=always --group-directories-first";
      lsize = "/usr/bin/du -hs * | sort -hr | less";
      # Processes;
      psa = "ps auxf";
      psgrep = "ps aux | grep -v grep | grep -i -e VSZ -e";
      psmem = "ps auxf | sort -nr -k 4";
      pscpu = "ps auxf | sort -nr -k 3";
      # Systemd;
      std = "sudo systemctl start";
      rrd = "sudo systemctl restart";
      stopd = "sudo systemctl stop";
      stts = "systemctl status";
      isfd = "systemctl is-failed";
      # Logging;
      lastjctl = "journalctl -p 3 -xb";
    };

    interactiveShellInit = ''
      # SWAP FISH AUTOSUGGESTION KEYS
      # TAB -> Accept suggestion
      bind \t accept-autosuggestion

      # Ctrl+F -> Show suggestions
      bind \cf complete

      # Remove greeting
      set fish_greeting
    '';

    functions = {
      fish_prompt = {
        body = ''
          set -l retc red
          test $status = 0; and set retc green
          set -l stts $status

          set -l retcode red
          test $status = 0; and set retcode normal

          set -q __fish_git_prompt_showupstream
          or set -g __fish_git_prompt_showupstream auto

          function _nim_prompt_wrapper
              set retc $argv[1]
              set -l field_name $argv[2]
              set -l field_value $argv[3]

              set_color normal
              set_color $retc
              echo -n '─'
              set_color -o green
              echo -n '['
              set_color normal
              test -n $field_name
              and echo -n $field_name:
              set_color $retc
              echo -n $field_value
              set_color -o green
              echo -n ']'
          end

          set_color $retc
          echo -n '┬─'
          set_color -o green
          echo -n [

          if functions -q fish_is_root_user; and fish_is_root_user
              set_color -o red
          else
              set_color -o yellow
          end

          echo -n $USER
          set_color -o normal
          echo -n @

          if test -z "$SSH_CLIENT"
              set_color -o blue
          else
              set_color -o cyan
          end

          echo -n (prompt_hostname)
          set_color -o normal
          echo -n :(prompt_pwd)
          set_color -o green
          echo -n ']'
          set_color $retc
          echo -n '─'
          set_color -o green
          echo -n '['
          set_color $retcode
          echo -n $stts
          set_color -o green
          echo -n ']'

          function fish_mode_prompt
          end

          # nix-shell indicator
          if set -q IN_NIX_SHELL
                  _nim_prompt_wrapper $retc N "nix-$IN_NIX_SHELL"
          end
          if test "$fish_key_bindings" = fish_vi_key_bindings
              or test "$fish_key_bindings" = fish_hybrid_key_bindings
              set -l mode
              switch $fish_bind_mode
                  case default
                      set mode (set_color --bold red)N
                  case insert
                      set mode (set_color --bold green)I
                  case replace_one
                      set mode (set_color --bold green)R
                      echo '[R]'
                  case replace
                      set mode (set_color --bold cyan)R
                  case visual
                      set mode (set_color --bold magenta)V
              end
              set mode $mode(set_color normal)
              _nim_prompt_wrapper $retc ''$mode
          end

          set -l prompt_git (fish_git_prompt '%s')
          test -n "$prompt_git"
          and _nim_prompt_wrapper $retc G $prompt_git

          type -q acpi
          and test (acpi -a 2> /dev/null | string match -r off)
          and _nim_prompt_wrapper $retc B (acpi -b | cut -d' ' -f 4-)

          echo

          set_color normal
          for job in (jobs)
              set_color $retc
              echo -n '│ '
              set_color brown
              echo $job
          end

          set_color normal
          set_color $retc
          echo -n '╰─>'
          set_color -o red
          echo -n '$ '
          set_color normal
        '';
      };

      # Nh alias
      nhhm = {
        body = ''
          nh home switch /etc/nixos#homeConfigurations.ak4m3@$argv[1].activationPackage
        '';
      };

      # yazi
      y = {
        body = ''
          set tmp (${pkgs.coreutils}/bin/mktemp -t "yazi-cwd.XXXXXX")
          ${lib.getExe pkgs.yazi} $argv --cwd-file="$tmp"
          if set cwd (command ${pkgs.coreutils}/bin/cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
              end
              ${pkgs.coreutils}/bin/rm -f -- "$tmp"
        '';
      };
    };
  };
}
