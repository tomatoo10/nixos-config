{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule {
  pname = "caido-mcp-server";
  version = "unstable";
  src = pkgs.fetchFromGitHub {
    owner = "c0tton-fluff";
    repo = "caido-mcp-server";
    rev = "main";
    hash = lib.fakeHash;
  };
  vendorHash = lib.fakeHash;
  subPackages = ["cmd/mcp"];
}
