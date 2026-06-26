# Docker runtime and user group wiring for hosts that need Docker directly.
{config, ...}: {
  virtualisation.docker.enable = true;
  users.users."${config.var.username}".extraGroups = ["docker"];
}
