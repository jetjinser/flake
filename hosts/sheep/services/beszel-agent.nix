{
  config,
  lib,
  ...
}:

let
  enable = false;

  inherit (config.sops) secrets;
  cfg = config.services.beszel-agent-preset;
in
{
  services.beszel-agent-preset = {
    inherit enable;
    tokenPath = secrets.hubToken.path;
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl+ILrZZwMAYH/x628CxX76/MeO1xMUPvbFQmy4LK0c";
    agentEnv = {
      EXTRA_FILESYSTEMS = "/persist";
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    hubToken = { };
  };
}
