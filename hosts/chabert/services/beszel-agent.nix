{
  config,
  lib,
  ...
}:

let
  enable = true;

  inherit (config.sops) secrets;
  cfg = config.services.beszel-agent-preset;
in
{
  services.beszel-agent-preset = {
    inherit enable;
    tokenPath = secrets.hubToken.path;
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAto51XPlgJ9xlsNRxHiRQEjyblK1JAO+54nGjLj/uk";
    agentEnv = {
      EXTRA_FILESYSTEMS = "/persist";
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    hubToken = { };
  };
}
