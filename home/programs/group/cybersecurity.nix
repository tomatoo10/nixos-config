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
    inputs.codex-cli-nix.packages.${pkgs.system}.default
    pkgs.claude-code
    bubblewrap
    # inputs.eleakxir.packages.${stdenv.hostPlatform.system}.leak-utils
  ];
}
