# shiro Home Manager config defines the server user's shell, SSH, and operator CLI tools; server services themselves are configured in NixOS host/media modules.
{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    # Mostly user-specific configuration
    ./variables.nix

    # Programs: use existing shared app configs, but keep plain neovim instead
    # of NVF to avoid DAP/Rust/debug tooling on the old laptop.
    ../../home/cli/shell
    ../../home/cli/ssh
    ../../home/cli/git
    ../../home/cli/git/lazygit.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      # Dev
      python3
      jq
      nh
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode

      # Utils
      zip
      unzip
      btop
      neovim
    ];

    # Don't touch this
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
  dconf.enable = lib.mkForce false;
  programs.man.enable = false;
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };
}
