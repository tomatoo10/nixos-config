{
  config,
  ...
}: {
  # Shared media group keeps apps and cleanup containers aligned on ownership.
  users.groups.media = {};
  users.users."${config.var.username}".extraGroups = ["media"];
}
