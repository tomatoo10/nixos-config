{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-multicursor" = {
      url = "github:jake-stewart/multicursor.nvim";
      flake = false;
    };
    
    # Overlay so i can use neovim nightly instead
    neovim-nightly-overlay = {  
      url = "github:nix-community/neovim-nightly-overlay";  
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      allowUnfree = true;
    };
    dependencyOverlays =  [
      (utils.standardPluginOverlay inputs)
    ];

    categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
      lspsAndRuntimeDeps = {
        deps = with pkgs; [
          universal-ctags
          ripgrep
          fd
        ];

        langs = with pkgs; [
          rust-analyzer
          clippy
          rustfmt
          nixd
        ];
      };
      
      startupPlugins = {
        general = with pkgs.vimPlugins; {
          always = [
            lze
            lzextras
            vim-repeat
            plenary-nvim
            nvim-notify
          ];
          extra = [
            nvim-web-devicons
          ];
        };
        themer = with pkgs.vimPlugins;
          (builtins.getAttr (categories.colorscheme or "onedark") {
              "onedark" = onedark-nvim;
              "catppuccin" = catppuccin-nvim;
              "catppuccin-mocha" = catppuccin-nvim;
              "tokyonight" = tokyonight-nvim;
              "tokyonight-day" = tokyonight-nvim;
              "gruvbox" = gruvbox;
            }
          );
      };

      optionalPlugins = {
        lint = with pkgs.vimPlugins; [
          nvim-lint
        ];

        format = with pkgs.vimPlugins; [
          conform-nvim
        ];

        general = {
          blink = with pkgs.vimPlugins; [
            luasnip
            cmp-cmdline
            blink-cmp
            blink-compat
            colorful-menu-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          utils = with pkgs.vimPlugins; [
            fzf-lua            
            pkgs.neovimPlugins.multicursor
            rustaceanvim
          ];
          core = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim 
            vim-sleuth
            nvim-surround
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            which-key-nvim
          ];
        };
      };

       sharedLibraries = {
        general = with pkgs; [         ];
      };

       python3.libraries = {
        test = (_:[]);
      };
      extraLuaPackages = {
        general = [ (_:[]) ];
      };
     };

     packageDefinitions = {
      nvim = { pkgs, name, ... }@misc: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          aliases = [ "vim" "vimcat" ];
          wrapRc = true;
          configDirName = "nixCats-nvim";
          hosts.python3.enable = true;
          hosts.node.enable = true;
          neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
        };
        categories = {
          langs = true;
          general = true;
          lint = true;
          format = true;
          themer = true;
          colorscheme = "gruvbox";
        };
        extra = {
          nixdExtras = {
            nixpkgs = ''import ${pkgs.path} {}'';
          };
        };
      };
    };

    defaultPackageName = "nvim";
  in
  forEachSystem (system: let
    
    nixCatsBuilder = utils.baseBuilder luaPath {
      
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
      
    } categoryDefinitions packageDefinitions;
    
    defaultPackage = nixCatsBuilder defaultPackageName;
    
    pkgs = import nixpkgs { inherit system; };
  in {
    
    packages = utils.mkAllWithDefault defaultPackage;

    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    };

  }) // (let
    
    nixosModule = utils.mkNixosModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    
    homeModule = utils.mkHomeModules {
      moduleNamespace = [ defaultPackageName ];
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
  in {

    overlays = utils.makeOverlays luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;

    nixosModules.default = nixosModule;
    homeModules.default = homeModule;

    inherit utils nixosModule homeModule;
    inherit (utils) templates;
  });

}
