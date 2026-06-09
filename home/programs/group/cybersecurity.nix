{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    wireshark
    nmap
    john
    hashcat
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.vigil.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.burpsuitepro.packages.${system}.default
    pkgs.claude-code
    caido-desktop
    bubblewrap
    # inputs.eleakxir.packages.${stdenv.hostPlatform.system}.leak-utils
  ];
}
