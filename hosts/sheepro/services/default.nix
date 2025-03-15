{
  flake,
  config,
  ...
}:

let
  inherit (config.sops) secrets;
  inherit (config.users) users;

  inherit (flake.config.lib) importx;

  purejs = "purejs.icu";
  cspTunnelID = "chez-sheepro";
in
{
  imports = importx ./. { };

  sops.secrets = {
    cspTunnelJson = { };
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    tunnelID = cspTunnelID;
    domain = purejs;
    credentialsFile = secrets.cspTunnelJson.path;
    certificateFile = secrets.originCert.path;
  };
}
