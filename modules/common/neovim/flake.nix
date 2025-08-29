{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";

    "plugins-multicursor" = {
      url = "github:jake-stewart/multicursor.nvim";
      flake = false;
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (inputs.nixCats) utils;
      luaPath = ./.;
      forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
      extra_pkg_config.allowUnfree = true;
      dependencyOverlays = [
        (utils.standardPluginOverlay inputs)
      ];

      categoryDefinitions =
        {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        }:
        {

          lspsAndRuntimeDeps = {
            deps = with pkgs; [
              # I can make LSPs available here or in my system, either by using nix-shell or systemPackages.
              universal-ctags
              ripgrep
              fd
              lua-language-server
              nil
            ];
          };

          startupPlugins = {
            # Not lazy loaded
            general = with pkgs.vimPlugins; {
              always = [
                lze
                lzextras
                vim-repeat
                plenary-nvim
                nvim-notify
                nvim-web-devicons
              ];
            };
            themer =
              with pkgs.vimPlugins;
              (builtins.getAttr (categories.colorscheme or "onedark") {
                "onedark" = onedark-nvim;
                "catppuccin" = catppuccin-nvim;
                "catppuccin-mocha" = catppuccin-nvim;
                "tokyonight" = tokyonight-nvim;
                "tokyonight-day" = tokyonight-nvim;
                "gruvbox" = gruvbox;
              });
          };

          optionalPlugins = {
            # Lazy loaded
            general = with pkgs.vimPlugins; [
              luasnip # I don't know
              cmp-cmdline # Cmd line completation
              blink-cmp # Completation
              blink-compat # compability layer for nvim-cmp
              colorful-menu-nvim # Enhance : command line in neovim

              nvim-treesitter.withAllGrammars # Syntax highlighting

              fzf-lua # Fuzzy finder
              pkgs.neovimPlugins.multicursor # Multicursor feature, maybe i change it to vim-multi bc of update on insert

              nvim-lspconfig # Configure LSPs
              lualine-nvim # Cool line
              vim-sleuth # Automatic fix tabs based on the file
              nvim-surround # Do i need it?

              fidget-nvim # Show LSP progress :D
              which-key-nvim # Show keysmaps

              # Langs
              rustaceanvim
            ];
          };
        };

      packageDefinitions = {
        nvim =
          {
            pkgs,
            name,
            ...
          }:
          {
            settings = {
              suffix-path = true;
              suffix-LD = true;
              aliases = [
                "vim"
                "vimcat"
              ];
              wrapRc = true;
              configDirName = "nvim";
              hosts.python3.enable = true;
              hosts.node.enable = true;
              neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
            };
            categories = {
              general = true;
              deps = true;
              themer = true;
              colorscheme = "gruvbox";
            };
          };
      };

      defaultPackageName = "nvim";
    in
    forEachSystem (
      system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit
            nixpkgs
            system
            dependencyOverlays
            extra_pkg_config
            ;
        } categoryDefinitions packageDefinitions;

        defaultPackage = nixCatsBuilder defaultPackageName;

        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = utils.mkAllWithDefault defaultPackage;

        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
            inputsFrom = [ ];
            shellHook = '''';
          };
        };
      }
    )
    // (
      let
        nixosModule = utils.mkNixosModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };

        homeModule = utils.mkHomeModules {
          moduleNamespace = [ defaultPackageName ];
          inherit
            defaultPackageName
            dependencyOverlays
            luaPath
            categoryDefinitions
            packageDefinitions
            extra_pkg_config
            nixpkgs
            ;
        };
      in
      {
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        nixosModules.default = nixosModule;
        homeModules.default = homeModule;

        inherit utils nixosModule homeModule;
        inherit (utils) templates;
      }
    );
}
