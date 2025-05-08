{
  flake,
  config,
  ...
}:

let
  inherit (config.sops) secrets;
  inherit (config.users) users;

  inherit (flake.config.lib) importx;

  bhu = "bhu.social";
  cspTunnelID = "sheepro-bhu";
in
{
  imports = importx ./. { };

  sops.secrets = {
    cspTunnelJson = { };
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    tunnelID = cspTunnelID;
    domain = bhu;
    credentialsFile = secrets.cspTunnelJson.path;
    certificateFile = secrets.originCert.path;
  };
}
