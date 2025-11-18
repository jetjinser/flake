{
  config,
  lib,
  ...
}:

let
  inherit (hub-cfg) enable;

  inherit (config.sops) secrets;
  hub-cfg = config.services.beszel.hub;
  cfg = config.services.beszel.agent;
in
{
  services.beszel.agent = {
    inherit enable;
    environment = {
      HUB_URL = "http://${hub-cfg.host}:${toString hub-cfg.port}";
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILAto51XPlgJ9xlsNRxHiRQEjyblK1JAO+54nGjLj/uk";
      LOG_LEVEL = "warn";
      # TOKEN_FILE = "$CREDENTIALS_DIRECTORY/hubToken";
      TOKEN_FILE = "/run/credentials/beszel-agent.service/hubToken";
      EXTRA_FILESYSTEMS = "/persist";
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    hubToken = { };
  };
  systemd.services.beszel-agent.serviceConfig.LoadCredential = "hubToken:${secrets.hubToken.path}";
}
