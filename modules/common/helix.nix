{pkgs, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night";
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
      };
    };
    languages.language = [
      # Nix
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
  };
}
