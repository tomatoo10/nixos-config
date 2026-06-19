{pkgs, ...}:
pkgs.buildGoModule {
  pname = "caido-mcp-server";
  version = "unstable";
  src = pkgs.fetchFromGitHub {
    owner = "c0tton-fluff";
    repo = "caido-mcp-server";
    rev = "main";
    hash = "sha256-qcnoMU6ReYR8g7aSE9DZ+rH7l1RqumWwr8I0QEKcocw=";
  };
  vendorHash = "sha256-s1jCJaG087oPmPUTM00RI+4QU0YcGX/I41lfmIHUZwk=";
  subPackages = ["cmd/mcp"];
}
