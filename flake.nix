{
  description = "NixOS flake for ryu (desktop) and sora (ThinkPad T14 Gen1 AMD)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    disko.url = "github:nix-community/disko";
    stylix.url = "github:danth/stylix";
    llm-agents.url = "github:numtide/llm-agents.nix";
    nvf.url = "github:notashelf/nvf";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    vigil.url = "github:tomatoo10/Vigil";
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix.url = "github:Mic92/sops-nix";
    # nixarr.url = "github:rasmus-kirk/nixarr";
  };

  outputs = inputs @ {nixpkgs, ...}: {
    nixosConfigurations = {
      ryu = nixpkgs.lib.nixosSystem {
        modules = [
          {
            _module.args = {
              inherit inputs;
            };
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.stylix.nixosModules.stylix
          ./hosts/ryu/configuration.nix
        ];
      };
      sora = nixpkgs.lib.nixosSystem {
        modules = [
          {
            nixpkgs.overlays = [];
            _module.args = {
              inherit inputs;
            };
          }
          inputs.home-manager.nixosModules.home-manager
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.stylix.nixosModules.stylix
          inputs.disko.nixosModules.disko
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
          ./hosts/sora/configuration.nix
        ];
      };
    };
  };
}
