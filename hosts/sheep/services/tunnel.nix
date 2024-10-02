{ orgUrl
, ...
}:

{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;
  enable = true;
in
{
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
        inherit enable;
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
