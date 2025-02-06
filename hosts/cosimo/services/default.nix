{
  flake,
  config,
  ...
}:

let
  inherit (flake.config.lib) importx;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  purejs = "purejs.icu";
  ccTunnelID = "chez-cosimo";
in
{
  imports = importx ./. { } ++ [
    flake.config.modules.nixos.services
  ];

  sops.secrets = {
    ccTunnelJson.owner = users.cloudflared.name;
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    enable = true;
    tunnelID = ccTunnelID;
    domain = purejs;
    credentialsFile = secrets.ccTunnelJson.path;
    originCert = secrets.originCert.path;
  };
}
