# Docker runtime and user group wiring for hosts that explicitly opt into Docker.
# Adding the user to docker grants near-root host access, so only enable it when needed.
{config, ...}: {
  virtualisation.docker.enable = true;
  users.users."${config.var.username}".extraGroups = ["docker"];
}
