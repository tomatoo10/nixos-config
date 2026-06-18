{pkgs, ...}:
pkgs.buildGoModule {
  pname = "caido-mcp-server";
  version = "unstable";
  src = pkgs.fetchFromGitHub {
    owner = "c0tton-fluff";
    repo = "caido-mcp-server";
    rev = "main";
    hash = "sha256-e6TZAb8JJqWZQilJDHuep3wPZ/NqKobITBvMPSNna4o=";
  };
  vendorHash = "sha256-s1jCJaG087oPmPUTM00RI+4QU0YcGX/I41lfmIHUZwk=";
  subPackages = ["cmd/mcp"];
}
