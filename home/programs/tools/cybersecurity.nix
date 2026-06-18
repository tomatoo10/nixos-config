{
  pkgs,
  inputs,
  lib,
  ...
}: let
  caido-mcp-server = import ../../../packages/caido-mcp.nix {inherit pkgs lib;};
in {
  home.packages = with pkgs; [
    caido-mcp-server
    nmap
    hashcat
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    inputs.vigil.packages.${pkgs.stdenv.hostPlatform.system}.default
    caido
    bubblewrap
    inputs.burpsuitepro.packages.${system}.default
    # inputs.eleakxir.packages.${stdenv.hostPlatform.system}.leak-utils
  ];
}
