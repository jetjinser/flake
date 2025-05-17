{
  flake,
  config,
  lib,
  ...
}:

let
  cfg = config.services;

  inherit (flake.config.lib) importx;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  bhu = "bhu.social";
  ccTunnelID = "chabert-bhu";
in
{
  imports = (importx ./. { }) ++ [
    flake.config.modules.nixos.services
  ];

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
