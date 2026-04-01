# starship is a minimal, fast, and extremely customizable prompt for any shell!
{
  config,
  lib,
  ...
}: let
  accent = "#${config.lib.stylix.colors.base0D}";
  background-alt = "#${config.lib.stylix.colors.base01}";
in {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "$hostname"
        "$username"
        "$directory"
        "$git_branch"
        "$status"
        "$nix_shell"
        # "$git_status"
        "\n"
        "$character"
      ];
      directory = {
        style = accent;
        truncation_length = 0;
        truncate_to_repo = false;
      };
      character = {
        success_symbol = "[➜](${accent})";
        error_symbol = "[➜](red)";
        vimcmd_symbol = "[➜](cyan)";
      };
      username = {
        show_always = true;
        format = "[$user](bold yellow) in ";
      };

      nix_shell = {
        format = "- \\[[$name]($style)\\] ";
        symbol = "";
        style = "bold blue";
      };

      status = {
        disabled = false;
        format = "- \\[[$status]($style)\\] ";
        style = "red";
        success_style = "white";
        success_symbol = "0";
        symbol = "";
      };
      git_branch = {
        symbol = "[](${background-alt}) ";
        style = "fg:${accent} bg:${background-alt}";
        format = "on [$symbol$branch]($style)[](${background-alt}) ";
      };
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218)($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };
    };
  };
}
