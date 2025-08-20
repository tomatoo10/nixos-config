{
  description = "Neovim derivation";

  # The function receives several key inputs:
  #
  # The normalized plugin configuration from neovimUtils.makeNeovimConfig
  # The generated init.lua content that sets up runtime paths
  # Wrapper arguments for environment variables and PATH extensions
  # The Bundling Process
  # Rather than literally bundling plugins into the binary itself, wrapNeovimUnstable creates a wrapper script that:
  #
  # Sets up the environment with proper PATH and environment variables mkNeovim.nix:158-175
  #
  # Configures plugin paths through the neovimConfig structure that tells Neovim where to find each plugin in the Nix store mkNeovim.nix:66-71
  #
  # Injects the custom init.lua that manages runtime path loading order mkNeovim.nix:122-156

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    multicursor-nvim = {
      url = "github:jake-stewart/multicursor.nvim";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    systems = builtins.attrNames nixpkgs.legacyPackages;

    # This is where the Neovim derivation is built.
    neovim-overlay = import ./nix/neovim-overlay.nix {inherit inputs;};
  in
    flake-utils.lib.eachSystem systems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
          neovim-overlay
          # This adds a function can be used to generate a .luarc.json
          # containing the Neovim API all plugins in the workspace directory.
          # The generated file can be symlinked in the devShell's shellHook.
          inputs.gen-luarc.overlays.default
        ];
      };
      shell = pkgs.mkShell {
        name = "nvim-devShell";
        buildInputs = with pkgs; [
          # Tools for Lua and Nix development, useful for editing files in this repo
          lua-language-server
          nil
          stylua
          luajitPackages.luacheck
          nvim-dev
        ];
        shellHook = ''
          # symlink the .luarc.json generated in the overlay
          ln -fs ${pkgs.nvim-luarc-json} .luarc.json
          # allow quick iteration of lua configs
          ln -Tfns $PWD/nvim ~/.config/nvim-dev
        '';
      };
    in {
      packages = rec {
        default = nvim;
        nvim = pkgs.nvim-pkg;
      };
      devShells = {
        default = shell;
      };
    })
    // {
      # You can add this overlay to your NixOS configuration
      overlays.default = neovim-overlay;
    };
}
