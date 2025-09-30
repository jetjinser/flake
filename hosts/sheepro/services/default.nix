{
  flake,
  config,
  lib,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  inherit (flake.config.lib) importx;

  bhu = "bhu.social";
  ccTunnelID = "sheepro-bhu";
in
{
  imports = importx ./. { };

  sops.secrets = lib.mkIf cfg.cloudflared'.enable {
    ccTunnelJson = { };
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    tunnelID = ccTunnelID;
    domain = bhu;
    credentialsFile = secrets.ccTunnelJson.path;
    certificateFile = secrets.originCert.path;
  };
}
