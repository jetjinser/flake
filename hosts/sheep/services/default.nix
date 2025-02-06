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
  csTunnelID = "chez-sheep";
in
{
  imports = (importx ./. { }) ++ [
    flake.config.modules.nixos.services
  ];

  sops.secrets = {
    csTunnelJson.owner = users.cloudflared.name;
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    enable = true;
    tunnelID = csTunnelID;
    domain = purejs;
    credentialsFile = secrets.csTunnelJson.path;
    originCert = secrets.originCert.path;
  };
}
