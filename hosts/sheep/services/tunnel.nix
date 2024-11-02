{ orgUrl
, ...
}:

{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;
  inherit (config.users) users;

  CFEnable = false;
in
{
  sops.secrets = lib.optionalAttrs CFEnable {
    SpOrgTunnelJson.owner = users.cloudflared.name;
  };

  services = {
    cloudflared =
      let
        IcuTunnelID = "dc88ef64-73e2-452c-a8fa-aef341fccf1c";

        serveIng = domain: subdomain: port: {
          "${subdomain}.${domain}" = "http://localhost:${toString port}";
        };

        serveOrgIng = serveIng orgUrl;
      in
      {
        enable = CFEnable;
        tunnels = {
          ${IcuTunnelID} = {
            credentialsFile = secrets.SpOrgTunnelJson.path;
            default = "http_status:404";
            ingress = lib.concatMapAttrs serveOrgIng
              {
                # ${atticdName} = atticdPort;
                # biliup = 19159;
              };
          };
        };
      };
  };
}
