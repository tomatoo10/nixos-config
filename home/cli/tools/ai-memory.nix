{pkgs, ...}: let
  ai-memory = import ../../../packages/ai-memory.nix {inherit pkgs;};
in {
  home.packages = [ai-memory];
}
